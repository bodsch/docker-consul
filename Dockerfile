
FROM alpine:3.7

ENV \
  TERM=xterm \
  TZ='Europe/Berlin' \
  BUILD_DATE="2018-01-18" \
  CONSUL_VERSION="1.0.2" \
  CONSUL_URL="https://releases.hashicorp.com/consul"

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

LABEL \
  version="1801" \
  maintainer="Bodo Schulz <bodo@boone-schulz.de>" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="Consul Docker Image" \
  org.label-schema.description="Inofficial Consul Docker Image" \
  org.label-schema.url="https://www.consul.io/" \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-consul" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${CONSUL_VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="GNU Lesser General Public License v2.1"

# ---------------------------------------------------------------------------------------

RUN \
  apk update --quiet --no-cache  && \
  apk upgrade --quiet --no-cache  && \
  apk add --no-cache --quiet --virtual .build-deps \
    ca-certificates curl unzip && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --cacert /etc/ssl/certs/ca-certificates.crt \
    --output /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip \
    "${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" && \
  unzip /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip -d /usr/bin/ && \
  apk --quiet --purge del .build-deps && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

VOLUME [ "/data" ]

ENTRYPOINT [ "/usr/bin/consul" ]

CMD [ "agent", "-data-dir", "/data" ]

# ---------------------------------------------------------------------------------------
