
FROM alpine:latest

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1704-01"

ENV \
  ALPINE_MIRROR="dl-cdn.alpinelinux.org" \
  ALPINE_VERSION="v3.5" \
  TERM=xterm \
  CONSUL_VERSION="0.8.0-rc1" \
  CONSUL_URL="https://releases.hashicorp.com/consul"

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

# ---------------------------------------------------------------------------------------

RUN \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk --no-cache update && \
  apk --no-cache upgrade && \
  apk --quiet add \
    ca-certificates \
    curl \
    unzip && \
  mkdir -p /opt/consul-web-ui && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --cacert /etc/ssl/certs/ca-certificates.crt \
    --output /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip \
    "${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --cacert /etc/ssl/certs/ca-certificates.crt \
    --output /tmp/consul_${CONSUL_VERSION}_web_ui.zip \
    "${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip" && \
  unzip /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip -d /bin/ && \
  unzip /tmp/consul_${CONSUL_VERSION}_web_ui.zip      -d /opt/consul-web-ui/ && \
  apk del --purge \
    curl \
    ca-certificates \
    unzip && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/consul" ]

CMD [ "agent", "-data-dir", "/data" ]

# ---------------------------------------------------------------------------------------
