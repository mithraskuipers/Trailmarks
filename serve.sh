#!/usr/bin/env bash
set -e

PORT="${1:-8000}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pick a python interpreter
if command -v python3 >/dev/null 2>&1; then
    PY=python3
elif command -v python >/dev/null 2>&1; then
    PY=python
else
    echo "Python is required but was not found in PATH." >&2
    exit 1
fi

# Find a LAN IP (best effort, works on Linux and macOS)
LAN_IP=""
if command -v hostname >/dev/null 2>&1; then
    LAN_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
fi
if [ -z "$LAN_IP" ] && command -v ipconfig >/dev/null 2>&1; then
    LAN_IP="$(ipconfig getifaddr en0 2>/dev/null)"
fi
if [ -z "$LAN_IP" ] && command -v ip >/dev/null 2>&1; then
    LAN_IP="$(ip route get 1 2>/dev/null | awk '{print $7; exit}')"
fi

LOCAL_URL="http://localhost:${PORT}/index.html"
NETWORK_URL=""
if [ -n "$LAN_IP" ]; then
    NETWORK_URL="http://${LAN_IP}:${PORT}/index.html"
fi

echo "Starting server on port ${PORT}..."
echo "Local:   ${LOCAL_URL}"
if [ -n "$NETWORK_URL" ]; then
    echo "Network: ${NETWORK_URL}"
fi
echo ""
echo "Press Ctrl+C to stop."

# Open browser once the server is reachable, without blocking startup
(
    for i in $(seq 1 20); do
        if command -v curl >/dev/null 2>&1 && curl -s -o /dev/null "http://localhost:${PORT}/"; then
            break
        fi
        sleep 0.25
    done
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$LOCAL_URL" >/dev/null 2>&1
    elif command -v open >/dev/null 2>&1; then
        open "$LOCAL_URL" >/dev/null 2>&1
    fi
) &

cd "$DIR"
exec "$PY" -m http.server "$PORT" --bind 0.0.0.0
