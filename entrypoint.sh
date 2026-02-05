#!/bin/sh
# Minimal supervisor for kspeeder:
# - Ensure default mirror config exists (for legacy docker mirror fallback)
# - Export KS_USER_NODES_CONFIG so the container defaults to /kspeeder-config/nodes.yaml
# - Run /usr/bin/kspeeder and restart it when it exits (it auto-stops ~ every 36h)
# - Stop cleanly on SIGTERM/SIGINT

APP="/usr/bin/kspeeder"
RESTART_DELAY="${KSPEEDER_RESTART_DELAY:-5}"   # seconds between restarts

# 1) Bootstrap config if not present
CONFIG_DIR="${KSPEEDER_CONFIG:-/kspeeder-config}"
CONFIG_FILE="${CONFIG_DIR}/kspeeder.yml"
# ensure config dir exists before we touch files
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR" 2>/dev/null || true
fi

if [ ! -f "$CONFIG_FILE" ]; then
  cat > "$CONFIG_FILE" << 'EOF'
mirrors:
EOF
fi

export KS_USER_MIRROR_CONFIG="$CONFIG_FILE"

# default nodes config path if the user did not supply one
if [ -z "${KS_USER_NODES_CONFIG:-}" ]; then
  export KS_USER_NODES_CONFIG="${CONFIG_DIR}/nodes.yaml"
fi

# 2) Simple supervise loop with trap
STOP=0
PID=""
trap 'STOP=1; [ -n "$PID" ] && kill -TERM "$PID" 2>/dev/null || true' INT TERM

while [ "$STOP" -eq 0 ]; do
  "$APP" &
  PID=$!
  wait "$PID" || true
  [ "$STOP" -eq 1 ] && break
  sleep "$RESTART_DELAY"
done

exit 0
