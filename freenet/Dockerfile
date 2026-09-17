# Syntax for multi-stage build
# syntax=docker/dockerfile:1

# ---------------------------------------------------------------------------
# Stage 1: Build Caddy with the security plugin (for OIDC)
# ---------------------------------------------------------------------------
FROM caddy:2-builder AS caddy-builder

RUN xcaddy build \
    --with github.com/greenpau/caddy-security \
    --output /usr/local/bin/caddy

# ---------------------------------------------------------------------------
# Stage 2: Assemble the app
# ---------------------------------------------------------------------------
FROM ghcr.io/freenet/freenet-core:latest

ARG BUILD_VERSION
ARG BUILD_ARCH
ARG S6_OVERLAY_VERSION=3.2.0.0

LABEL \
  io.hass.version="0.0.13" \
  io.hass.type="app" \
  io.hass.arch="aarch64|amd64"

# Install s6-overlay and dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         ca-certificates curl xz-utils jq gosu \
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${BUILD_ARCH}.tar.xz /tmp

RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${BUILD_ARCH}.tar.xz \
    && rm /tmp/*.tar.xz

# Copy custom Caddy build
COPY --from=caddy-builder /usr/local/bin/caddy /usr/local/bin/caddy

# Copy s6 service definitions
COPY rootfs /

RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run \
    && mkdir -p /data/freenet /etc/caddy \
    && chmod 755 /etc/caddy \
    && chown -R freenet:freenet /data \
    && chmod +x /etc/s6-overlay/s6-rc.d/00-render-config/up/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/freenet-core/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/caddy/run \
    && sed -i 's/\r$//' /etc/s6-overlay/s6-rc.d/00-render-config/up/run \
    && sed -i 's/\r$//' /etc/s6-overlay/s6-rc.d/freenet-core/run \
    && sed -i 's/\r$//' /etc/s6-overlay/s6-rc.d/caddy/run

# s6-overlay must be PID 1
ENTRYPOINT ["/init"]
CMD []
