#!/usr/bin/env bash
set -e

SERVICE=$1
URL=$2

echo "🔍 Healthcheck für $SERVICE auf $URL..."

# bis zu 10 Sekunden warten
for i in {1..10}; do
  if curl -fsS "$URL" > /dev/null 2>&1; then
    echo "✅ $SERVICE ist gesund"
    exit 0
  else
    echo "⏳ Versuch $i/10..."
    sleep 1
  fi
done

echo "❌ $SERVICE ist NICHT gesund!"
exit 1
