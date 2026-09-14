#!/usr/bin/with-contenv bashash
set -euo pipefail

# Supervisor renders user options into these env vars
CONFIG_FILE="/data/options.json"

# Read configuration
LISTEN_PORT=$(jq -r '.listen_port' "${CONFIG_FILE}")
NODE_ADDRESS=$(jq -r '.node_address' "${CONFIG_FILE}")
NODE_PORT=$(jq -r '.node_port' "${CONFIG_FILE}")
AUTH_MODE=$(jq -r '.auth_mode' "${CONFIG_FILE}")
CF_ACCESS_ENABLED=$(jq -r '.cf_access_enabled' "${CONFIG_FILE}")
PANGOLIN_ENABLED=$(jq -r '.pangolin_enabled' "${CONFIG_FILE}")
OIDC_ENABLED=$(jq -r '.oidc_enabled' "${CONFIG_FILE}")

# Generate Caddyfile based on auth mode
cat > /etc/caddy/Caddyfile <<EOF
:{{ LISTEN_PORT }} {
{{ if [ "$AUTH_MODE" == "cloudflare_access" ] }}
    # Cloudflare Access validates at the edge
    # We trust the edge to handle auth
{{ elif [ "$AUTH_MODE" == "pangolin" ] }}
    # Pangolin validates at the edge, we trust it
{{ elif [ "$AUTH_MODE" == "oidc" ] }}
    # OIDC validation via Caddy OIDC module
    # Requires Caddy with oidc module installed
{{ fi }}

    reverse_proxy {{ NODE_ADDRESS }}:{{ NODE_PORT }} {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
        
        # WebSocket support - critical for Freenet API
        transport websocket {
            upgrade $http_upgrade
            connection $connection
        }
        
        flush_interval -1
        buf_size -1
    }
    
    # Health check
    respond /health "OK" 200
}
EOF

# Start Caddy
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile