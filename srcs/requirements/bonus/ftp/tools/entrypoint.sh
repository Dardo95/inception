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

FTP_PASS="$(cat "$PASS_FILE")"

# Crear usuario si no existe
if ! id "$FTP_USER" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASS" | chpasswd

# Asegura que el target existe y asigna permisos
mkdir -p /var/www/html
chown -R "$FTP_USER:$FTP_USER" /var/www/html

# IMPORTANTE: hacer que el usuario caiga en /var/www/html al conectar
usermod -d /var/www/html "$FTP_USER"

exec /usr/sbin/vsftpd /etc/vsftpd.conf
