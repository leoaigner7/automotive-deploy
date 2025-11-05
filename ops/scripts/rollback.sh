#!/usr/bin/env bash
set -euo pipefail

SERVICE="$1"
STATE_DIR="$(cd .. && pwd)/state"
PREV_VERSION_FILE="$STATE_DIR/${SERVICE}.previous"
COMPOSE_FILE="/ops/compose/docker-compose.yml"

if [ ! -f "$PREV_VERSION_FILE" ]; then
  echo "No previous version for ${SERVICE}"; exit 1
fi
VERSION="$(cat "$PREV_VERSION_FILE")"
sed -i "s/^VERSION=.*/VERSION=${VERSION}/" /ops/compose/.env || echo "VERSION=${VERSION}" >> /ops/compose/.env

echo "↩️  Rolling back ${SERVICE} to ${VERSION}"
/usr/bin/docker compose -f "$COMPOSE_FILE" stop "$SERVICE" || true
CID=$(/usr/bin/docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE" 2>/dev/null || true)
[ -n "$CID" ] && /usr/bin/docker rm -f "$CID" 2>/dev/null || true
/usr/bin/docker rm -f $(/usr/bin/docker ps -aq --filter "name=${SERVICE}") 2>/dev/null || true
/usr/bin/docker compose -f "$COMPOSE_FILE" up -d --no-deps --force-recreate "$SERVICE"
echo "✅ Rollback done"
