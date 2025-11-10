#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="automotive-deploy"
PROJECT_DIR="$HOME/$PROJECT_NAME"
BUILD_DIR="$HOME/build/artifacts"
VERSION_FILE="$PROJECT_DIR/VERSION"

# Version ermitteln
if [[ -f "$VERSION_FILE" ]]; then
  VERSION=$(cat "$VERSION_FILE")
else
  VERSION="1.0.0"
fi

ARTIFACT_NAME="${PROJECT_NAME}-${VERSION}.tar.gz"
ARTIFACT_PATH="${BUILD_DIR}/${ARTIFACT_NAME}"

mkdir -p "$BUILD_DIR"

# Deploy-Skript kopieren, damit BMW später nur ./deploy.sh aufrufen muss
cp "$PROJECT_DIR/ops/scripts/deploy.sh" "$PROJECT_DIR/deploy.sh"
chmod +x "$PROJECT_DIR/deploy.sh"

echo "📦  Erstelle Artifact unter: $ARTIFACT_PATH"
tar -czf "$ARTIFACT_PATH" -C "$HOME" "$PROJECT_NAME"

echo "✅  Fertig! Artifact erstellt: $ARTIFACT_PATH"

