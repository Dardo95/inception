#!/bin/sh
set -eu

PASS_FILE="/run/secrets/portainer_admin_password"

if [ ! -f "$PASS_FILE" ]; then
  echo "Missing secret: portainer_admin_password" >&2
  exit 1
fi

exec /opt/portainer/portainer \
  -H unix:///var/run/docker.sock \
  --data /data \
  --admin-password-file "$PASS_FILE"
