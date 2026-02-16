#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/inception.key ] || [ ! -f /etc/nginx/ssl/inception.crt ]; then
  echo "[NGINX] Generating self-signed certificate..."
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -days 365 \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=enogueir.42.fr"
fi

echo "[NGINX] Starting..."
exec nginx -g "daemon off;"
