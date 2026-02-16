FROM debian:bookworm-slim

ARG PORTAINER_VERSION=2.33.7
ARG PORTAINER_ARCH=linux-amd64

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl tar \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/portainer \
    && curl -fsSL -o /tmp/portainer.tar.gz \
      "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-${PORTAINER_ARCH}.tar.gz" \
    && tar -xzf /tmp/portainer.tar.gz -C /opt \
    && rm -f /tmp/portainer.tar.gz \
    && chmod +x /opt/portainer/portainer

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /opt/portainer

EXPOSE 9000 9443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
