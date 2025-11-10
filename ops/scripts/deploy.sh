#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-}"; VERSION="${2:-}"
if [[ -z "$SERVICE" || -z "$VERSION" ]]; then
  echo "Usage: $0 <service> <version>"
  exit 1
fi

export VERSION="$VERSION"
echo ">> Deploy $SERVICE:$VERSION"

# ---------- Docker installieren, falls nicht vorhanden ----------
if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Docker wird installiert..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y docker.io docker-compose-plugin
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y docker docker-compose
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y docker docker-compose
  else
    echo "❌ Kein kompatibler Paketmanager gefunden"; exit 1
  fi
  sudo systemctl enable --now docker || true
  sudo usermod -aG docker "$USER" || true
  echo "✅ Docker wurde installiert"
fi

# ---------- Docker Compose prüfen ----------
if ! docker compose version >/dev/null 2>&1; then
  echo "⚙️  Docker Compose (v2) wird installiert..."
  # auf Debian/Ubuntu:
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y docker-compose-plugin || true
  fi
fi

# ---------- Compose-Ordner finden ----------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_DIR="$PROJECT_ROOT/compose"

if [[ ! -f "$COMPOSE_DIR/docker-compose.yml" ]]; then
  echo "❌ keine docker-compose.yml unter $COMPOSE_DIR gefunden"
  exit 1
fi

cd "$COMPOSE_DIR"

# ---------- Compose ausführen ----------
echo "🚀 docker compose up für $SERVICE..."
docker compose -f docker-compose.yml up -d --build --no-deps --force-recreate "$SERVICE"

# ---------- Healthcheck ----------
if [[ "$SERVICE" == "hello-service" ]]; then
  HEALTH_URL="http://hello-service:9090/health"
else
  HEALTH_URL="http://localhost:8088/health"
fi

echo "⏳ Warte auf Health: $HEALTH_URL"
for i in $(seq 1 30); do
  if curl -sS "$HEALTH_URL" | grep -q '"ok":\s*true'; then
    echo "✅ $SERVICE healthy"
    exit 0
  fi
  sleep 2
done

echo "⚠️  Healthcheck Timeout (Container läuft weiter)."
exit 0
