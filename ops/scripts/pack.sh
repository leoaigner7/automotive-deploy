#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
OUT_DIR="$ROOT_DIR/out"
VERSION_FILE="$ROOT_DIR/VERSION"
VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "0.0.1")

mkdir -p "$OUT_DIR/images"

echo "📦 Baue Offline-Bundle für Version $VERSION..."

# -------------------------------------------------
# 1️⃣ Docker Images speichern
# -------------------------------------------------
echo "🧊 Speichere Docker-Images..."
docker save local/hello-service:$VERSION -o "$OUT_DIR/images/hello-service-$VERSION.tar" || echo "⚠️ hello-service fehlgeschlagen"
docker save local/deploy-backend:$VERSION -o "$OUT_DIR/images/backend-$VERSION.tar" || echo "⚠️ backend fehlgeschlagen"
docker save local/deploy-frontend:$VERSION -o "$OUT_DIR/images/frontend-$VERSION.tar" || echo "⚠️ frontend fehlgeschlagen"

# Kombiniere alle Images zu einem Archiv
tar -cf "$OUT_DIR/images-$VERSION.tar" -C "$OUT_DIR/images" .
gzip -f "$OUT_DIR/images-$VERSION.tar"

echo "✅ Docker Images gepackt: $OUT_DIR/images-$VERSION.tar.gz"

# -------------------------------------------------
# 2️⃣ Quellcode & Deploy-Skripte mit ins Bundle
# -------------------------------------------------
mkdir -p "$ROOT_DIR/workspace"
cp -r "$ROOT_DIR/hello-service" "$ROOT_DIR/workspace/" 2>/dev/null || echo "⚠️ hello-service fehlt"
cp -r "$ROOT_DIR/backend" "$ROOT_DIR/workspace/" 2>/dev/null || echo "⚠️ backend fehlt"
cp -r "$ROOT_DIR/frontend" "$ROOT_DIR/workspace/" 2>/dev/null || echo "⚠️ frontend fehlt"

tar -czf "$OUT_DIR/artifact-${VERSION}.tar.gz" \
    -C "$ROOT_DIR" ops/compose \
    ops/scripts \
    VERSION \
    workspace \
    README.md \
    out/images-$VERSION.tar.gz

# -------------------------------------------------
# 3️⃣ Checksummen erzeugen
# -------------------------------------------------
(cd "$OUT_DIR" && sha256sum artifact-${VERSION}.tar.gz > checksums.txt)

echo "✅ Bundle fertig: $OUT_DIR/artifact-${VERSION}.tar.gz"
ls -lh "$OUT_DIR/"
