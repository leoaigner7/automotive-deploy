#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starte Offline-Deployment..."

ARCHIVE=$(ls automotive-deploy-v*.tar.gz 2>/dev/null | head -n1)
if [ -z "$ARCHIVE" ]; then
  echo "❌ Kein Bundle gefunden!"
  exit 1
fi

echo "📦 Entpacke ${ARCHIVE}..."
tar -xzf "$ARCHIVE"

cd automotive-deploy

if ! command -v docker &>/dev/null; then
  echo "🐋 Installiere Docker..."
  sudo apt-get update -y
  sudo apt-get install -y docker.io
fi

if [ -d "out/images" ]; then
  echo "🐳 Lade gespeicherte Docker-Images..."
  for img in out/images/*.tar; do
    echo "   → $img"
    docker load -i "$img"
  done
else
  echo "⚠️ Keine gespeicherten Images gefunden – Compose baut neu."
fi

echo "▶️ Starte Docker-Stack..."
cd ops/compose
docker compose up -d --build

echo "✅ Deployment abgeschlossen! App läuft."
