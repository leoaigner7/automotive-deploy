#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:?service missing}"
VERSION="${2:?version missing}"

export VERSION="$VERSION"

# ---- WICHTIG: Wechsle in den Compose-Ordner ----
cd /workspace/ops/compose

echo ">> Deploy $SERVICE:$VERSION"

# ---- Compose ausführen ----
docker compose -f docker-compose.yml up -d --build --no-deps --force-recreate "$SERVICE"

# ---- Healthcheck ----
# ---- Healthcheck ----
if [[ "$SERVICE" == "hello-service" ]]; then
  HEALTH_URL="http://hello-service:9090/health"
else
  HEALTH_URL="http://localhost:8088/health"
fi


echo ">> Warte auf Health: $HEALTH_URL"
for i in {1..30}; do
  if curl -sS "$HEALTH_URL" | grep -q '"ok":\s*true'; then
    echo "✅ $SERVICE healthy"
    exit 0
  fi
  sleep 1
done

echo "⚠️  Healthcheck Timeout (weiterhin läuft der Container)."
exit 0
