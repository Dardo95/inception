#!/bin/sh
set -eu

PASS_FILE="/run/secrets/ftp_password"

if [ -z "${FTP_USER:-}" ]; then
  echo "Missing env: FTP_USER" >&2
  exit 1
fi
if [ ! -f "$PASS_FILE" ]; then
  echo "Missing secret: ftp_password" >&2
  exit 1
fi
if [ -z "${HOST_IP:-}" ]; then
  echo "Missing env: HOST_IP (needed for FTP passive mode)" >&2
  exit 1
fi
if [ -z "${FTP_UID:-}" ] || [ -z "${FTP_GID:-}" ]; then
  echo "Missing env: FTP_UID/FTP_GID" >&2
  exit 1
fi
if [ -z "${FTP_PASV_MIN:-}" ] || [ -z "${FTP_PASV_MAX:-}" ]; then
  echo "Missing env: FTP_PASV_MIN/FTP_PASV_MAX" >&2
  exit 1
fi

envsubst '${HOST_IP} ${FTP_PASV_MIN} ${FTP_PASV_MAX}' < /etc/vsftpd.conf.template > /etc/vsftpd.conf

FTP_PASS="$(cat "$PASS_FILE")"

# Reutilizamos el UID/GID de www-data para que lo subido por FTP tenga
# los mismos permisos que los archivos que gestiona php-fpm en el mismo
# volumen. -o permite UID/GID no únicos (www-data ya usa 33:33).
if ! getent group "$FTP_GID" >/dev/null 2>&1; then
  groupadd -o -g "$FTP_GID" ftpgroup
fi

if ! id "$FTP_USER" >/dev/null 2>&1; then
  useradd -o -u "$FTP_UID" -g "$FTP_GID" -M -d /var/www/html -s /usr/sbin/nologin "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASS" | chpasswd

mkdir -p /var/www/html
chown -R "$FTP_UID:$FTP_GID" /var/www/html

exec /usr/sbin/vsftpd /etc/vsftpd.conf