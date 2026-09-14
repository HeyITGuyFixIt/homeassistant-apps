ARG BUILD_FROM
FROM ghcr.io/freenet/freenet-core:latest

COPY run.sh /etc/cont-init.d/60-freenet-config
COPY run.sh /etc/services.d/freenet/run

RUN chmod +x /etc/cont-init.d/60-freenet-config \
          && chmod +x /etc/services.d/freenet/run