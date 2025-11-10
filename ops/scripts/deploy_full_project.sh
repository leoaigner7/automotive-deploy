#!/usr/bin/env bash
set -euo pipefail

# Variablen (Bitte anpassen)
SOURCE_DIR="/home/leo/automotive-deploy"  # Pfad zu deinem Projektverzeichnis auf deinem Quellhost A
TARGET_HOST="aigner@192.168.56.102"                # Ersetze 'leo' mit deinem Benutzernamen auf Zielhost B und 'zielhost' mit der IP-Adresse oder dem Hostnamen des Zielhosts
TARGET_DIR="/home/aigner/automotive-deploy"  # Zielverzeichnis auf Zielhost B (z. B. /home/leo/automotive-deploy)

# 1. Übertragung des gesamten Projekts auf den Zielhost
echo "Übertrage das Projekt nach Zielhost B..."
scp -r $SOURCE_DIR $TARGET_HOST:$TARGET_DIR

# 2. Docker auf Zielhost B installieren, falls es nicht installiert ist
echo "Prüfe und installiere Docker auf Zielhost B..."
ssh $TARGET_HOST "which docker || sudo apt-get update && sudo apt-get install -y docker.io"

# 3. Docker Compose auf Zielhost B installieren, falls es nicht installiert ist
echo "Prüfe und installiere Docker Compose auf Zielhost B..."
ssh $TARGET_HOST "which docker-compose || sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose"

# 4. Wechsel ins Verzeichnis des Projekts auf Zielhost B
echo "Wechsel in das Verzeichnis des Projekts auf Zielhost B..."
ssh $TARGET_HOST "cd $TARGET_DIR/ops/compose"

# 5. Docker Compose für alle Services ausführen
echo "Starte Docker-Container für das gesamte Projekt auf Zielhost B..."
ssh $TARGET_HOST "cd $TARGET_DIR/ops/compose && docker-compose -f docker-compose.yml up -d --build --no-deps --force-recreate"

# 6. Healthcheck für alle Services ausführen
echo "Führe Healthchecks für alle Services aus..."
for SERVICE in backend frontend hello-service; do
    echo "Prüfe Healthcheck für $SERVICE..."
    if [[ "$SERVICE" == "hello-service" ]]; then
        HEALTH_URL="http://hello-service:9090/health"
    else
        HEALTH_URL="http://localhost:8088/health"
    fi

    # Warte auf den erfolgreichen Healthcheck
    for i in {1..30}; do
        if curl -sS "$HEALTH_URL" | grep -q '"ok":\s*true'; then
            echo "✅ $SERVICE ist gesund!"
            break
        fi
        if [[ $i -eq 30 ]]; then
            echo "❌ Healthcheck für $SERVICE fehlgeschlagen nach 30 Versuchen!"
            exit 1
        fi
        sleep 1
    done
done

echo "Deployment abgeschlossen! Alle Services laufen."
exit 0
