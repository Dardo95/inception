#!/bin/bash
set -e

if [ -z "${DOMAIN_NAME:-}" ]; then
  echo "[NGINX] Missing env: DOMAIN_NAME" >&2
  exit 1
fi

envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/inception.key ] || [ ! -f /etc/nginx/ssl/inception.crt ]; then
  echo "[NGINX] Generating self-signed certificate..."
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -days 365 \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi

echo "[NGINX] Starting..."
exec nginx -g "daemon off;"
