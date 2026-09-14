ARG BUILD_FROM
FROM caddy:latest

# Install jq for config parsing (optional, if you want dynamic config)
RUN apk add --no-cache jq

# Copy Caddyfile template and run script
COPY Caddyfile /etc/caddy/Caddyfile.template
COPY run.sh /etc/cont-init.d/60-caddy-config
COPY run.sh /etc/services.d/caddy/run

RUN chmod +x /etc/cont-init.d/60-caddy-config \
          && chmod +x /etc/services.d/caddy/run

# Caddyfile will be rendered at runtime
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]