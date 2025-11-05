#!/usr/bin/env bash
set -euo pipefail

SERVICE="$1"
VERSION="$2"
NO_SAVE="${3:-""}"

STATE_DIR="$(cd .. && pwd)/state"
CURRENT_VERSION_FILE="$STATE_DIR/${SERVICE}.current"
PREV_VERSION_FILE="$STATE_DIR/${SERVICE}.previous"
COMPOSE_FILE="/ops/compose/docker-compose.yml"
HEALTH_URL="http://localhost:9090/health"

LOCK_FILE="/tmp/deploy.${SERVICE}.lock"
exec 9>"${LOCK_FILE}"
if ! flock -n 9; then
  echo "Another deployment for ${SERVICE} is already running"; exit 1
fi
trap 'rm -f "${LOCK_FILE}" || true' EXIT

# Set VERSION in compose .env
sed -i "s/^VERSION=.*/VERSION=${VERSION}/" /ops/compose/.env || echo "VERSION=${VERSION}" >> /ops/compose/.env

# Save old version
if [ -f "$CURRENT_VERSION_FILE" ] && [ "${NO_SAVE}" != "--no-save" ]; then
  cp "$CURRENT_VERSION_FILE" "$PREV_VERSION_FILE"
fi
echo "$VERSION" > "$CURRENT_VERSION_FILE"

echo "🛑 Stopping $SERVICE"
/usr/bin/docker compose -f "$COMPOSE_FILE" stop "$SERVICE" || true
CID=$(/usr/bin/docker compose -f "$COMPOSE_FILE" ps -q "$SERVICE" 2>/dev/null || true)
[ -n "$CID" ] && /usr/bin/docker rm -f "$CID" 2>/dev/null || true
/usr/bin/docker rm -f $(/usr/bin/docker ps -aq --filter "name=${SERVICE}") 2>/dev/null || true

echo "🏗️ Building image ${SERVICE}:${VERSION}"
/usr/bin/docker compose -f "$COMPOSE_FILE" build "$SERVICE"

echo "🏷️ Tagging ${SERVICE}:local → ${SERVICE}:${VERSION}"
/usr/bin/docker tag ${SERVICE}:local ${SERVICE}:${VERSION}

echo "🚀 Starting $SERVICE (v${VERSION})"
/usr/bin/docker compose -f "$COMPOSE_FILE" up -d --no-deps --force-recreate "$SERVICE"

echo "🩺 Checking health ${HEALTH_URL}"
end=$((SECONDS+60))
ok=0
while [ $SECONDS -lt $end ]; do
  if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then ok=1; break; fi
  sleep 2
done

if [ $ok -eq 1 ]; then
  echo "✅ Deployment erfolgreich"
else
  echo "❌ Deployment fehlgeschlagen → Rollback"
  /ops/scripts/rollback.sh "$SERVICE"
  exit 1
fi
