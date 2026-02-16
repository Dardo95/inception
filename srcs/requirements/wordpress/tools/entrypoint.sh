#!/bin/bash
set -e

DOMAIN="${DOMAIN_NAME}"

DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_HOST="mariadb"
DB_PASS_FILE="${MYSQL_PASSWORD_FILE}"

WP_TITLE="${WP_TITLE}"
WP_ADMIN_USER="${WP_ADMIN_USER}"
WP_ADMIN_EMAIL="${WP_ADMIN_EMAIL}"
WP_ADMIN_PASS_FILE="${WP_ADMIN_PASSWORD_FILE}"

WP_USER_USER="${WP_USER_USER}"
WP_USER_EMAIL="${WP_USER_EMAIL}"
WP_USER_PASS_FILE="${WP_USER_PASSWORD_FILE}"

if [ -z "$DOMAIN" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS_FILE" ]; then
  echo "Missing required env for WordPress DB."
  exit 1
fi

DB_PASS="$(cat "$DB_PASS_FILE")"

# Basic safety: ensure wp directory exists
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# Download WordPress core if not present
if [ ! -f "/var/www/html/wp-settings.php" ]; then
  echo "[WP] Downloading WordPress core..."
  wp core download --path=/var/www/html --allow-root
  chown -R www-data:www-data /var/www/html
fi

# Wait for MariaDB
echo "[WP] Waiting for MariaDB..."
for i in {1..60}; do
  if mariadb -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Create wp-config.php if missing
if [ ! -f "/var/www/html/wp-config.php" ]; then
  echo "[WP] Creating wp-config.php..."
  wp config create \
    --path=/var/www/html \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASS" \
    --dbhost="$DB_HOST" \
    --skip-check \
    --allow-root

  wp config set WP_DEBUG false --raw --path=/var/www/html --allow-root
  chown -R www-data:www-data /var/www/html
fi

# Install WordPress only if not installed
if ! wp core is-installed --path=/var/www/html --allow-root >/dev/null 2>&1; then
  echo "[WP] Installing WordPress..."
  ADMIN_PASS="$(cat "$WP_ADMIN_PASS_FILE")"
  USER_PASS="$(cat "$WP_USER_PASS_FILE")"

  wp core install \
    --path=/var/www/html \
    --url="https://${DOMAIN}" \
    --title="${WP_TITLE:-Inception}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  echo "[WP] Creating second user..."
  wp user create \
    "${WP_USER_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${USER_PASS}" \
    --role=author \
    --path=/var/www/html \
    --allow-root

  chown -R www-data:www-data /var/www/html
else
  echo "[WP] WordPress already installed. Skipping install."
fi

REDIS_MARKER="/var/www/html/.redis_configured"

if [ ! -f "$REDIS_MARKER" ]; then
  echo "[WP] Setting up Redis cache..."
  wp plugin install redis-cache --activate --path=/var/www/html --allow-root || true
  wp config set WP_REDIS_HOST redis --type=constant --path=/var/www/html --allow-root
  wp config set WP_REDIS_PORT 6379 --raw --type=constant --path=/var/www/html --allow-root
  wp redis enable --path=/var/www/html --allow-root || true
  touch "$REDIS_MARKER"
  chown www-data:www-data "$REDIS_MARKER"
fi

echo "[WP] Starting php-fpm..."
exec php-fpm8.2 -F
