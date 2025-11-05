#!/usr/bin/env bash
set -euo pipefail
curl -fsS http://localhost:8080/health >/dev/null
curl -fsS http://localhost:9090/health >/dev/null
echo "✅ Smoke-Test erfolgreich"

