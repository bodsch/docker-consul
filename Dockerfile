
FROM bodsch/docker-alpine-base:1701-02

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.1.0"

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENV CONSUL_VERSION 0.7.2

# ---------------------------------------------------------------------------------------

RUN \
  apk --no-cache update && \
  apk --no-cache upgrade && \
  mkdir /opt/consul-web-ui && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --cacert /etc/ssl/certs/ca-certificates.crt \
    --output /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip \
    "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --cacert /etc/ssl/certs/ca-certificates.crt \
    --output /tmp/consul_${CONSUL_VERSION}_web_ui.zip \
    "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_web_ui.zip" && \
  unzip /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip -d /bin/ && \
  unzip /tmp/consul_${CONSUL_VERSION}_web_ui.zip      -d /opt/consul-web-ui/ && \
  apk del --purge \
    bash \
    nano \
    tree \
    curl \
    ca-certificates \
    supervisor && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/consul" ]

CMD [ "agent", "-data-dir", "/data" ]

# ---------------------------------------------------------------------------------------
