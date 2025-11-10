#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
OUT_DIR="$ROOT_DIR/out"
VERSION_FILE="$ROOT_DIR/VERSION"
VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "0.0.1")

mkdir -p "$OUT_DIR"

echo "📦 Baue Offline-Bundle für Version $VERSION..."

# Optional: Docker-Images sichern (nur falls Compose vorhanden)
if [ -f "$ROOT_DIR/ops/compose/docker-compose.yml" ]; then
  echo "🧊 Speichere Docker-Images..."
  mkdir -p "$OUT_DIR/images"
  docker compose -f "$ROOT_DIR/ops/compose/docker-compose.yml" config --services | while read svc; do
    image=$(docker compose -f "$ROOT_DIR/ops/compose/docker-compose.yml" config | grep "image:" | grep "$svc" | head -n1 | awk '{print $2}')
    if [ -n "$image" ]; then
      echo "  → $image"
      docker save "$image" -o "$OUT_DIR/images/${svc}.tar" || echo "⚠️ $svc konnte nicht gespeichert werden"
    fi
  done
fi

# Workspace-Ordner hinzufügen (Services)
mkdir -p "$ROOT_DIR/workspace"
cp -r "$ROOT_DIR/hello-service" "$ROOT_DIR/workspace/" 2>/dev/null || echo "⚠️ hello-service nicht gefunden"
cp -r "$ROOT_DIR/backend" "$ROOT_DIR/workspace/" 2>/dev/null || echo "⚠️ backend nicht gefunden"
cp -r "$ROOT_DIR/frontend" "$ROOT_DIR/workspace/" 2>/dev/null || echo "⚠️ frontend nicht gefunden"

# Artefakte sammeln
tar -czf "$OUT_DIR/artifact-${VERSION}.tar.gz" \
    -C "$ROOT_DIR" ops/compose \
    ops/scripts \
    config \
    workspace \
    VERSION \
    README.md 2>/dev/null || true

# Checksum erzeugen
(cd "$OUT_DIR" && sha256sum artifact-${VERSION}.tar.gz > checksums.txt)

echo "✅ Bundle fertig: $OUT_DIR/artifact-${VERSION}.tar.gz"
