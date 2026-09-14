#!/usr/bin/with-contenv bashash
set -euo pipefail

# Supervisor renders user options into these env vars
CONFIG_DIR="/data/options.json"
FREENET_DATA="/data/freenet"

mkdir -p "${FREENET_DATA}"

# Pull option values out of the Supervisor-provided JSON
WS_PORT=$(jq -r '.ws_port' "${CONFIG_DIR}")
HTTP_PORT=$(jq -r '.http_port' "${CONFIG_DIR}")
STORAGE=$(jq -r '.storage_mb' "${CONFIG_DIR}")
OPENNET=$(jq -r '.opennet' "${CONFIG_DIR}")

# freenet-core reads a TOML config; generate it from HA options
cat > /data/freenet.toml <<EOF
ws-server-listen-port = ${WS_PORT}
http-gateway-port = ${HTTP_PORT}
storage-directory = "${FREENET_DATA}"
storage-capacity = ${STORAGE}
opennet = ${OPENNET}
EOF

exec freenet-core --config /data/freenet.toml