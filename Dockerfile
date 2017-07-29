
FROM alpine:3.6

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

ENV \
  ALPINE_MIRROR="mirror1.hs-esslingen.de/pub/Mirrors" \
  ALPINE_VERSION="v3.6" \
  TERM=xterm \
  BUILD_DATE="2017-07-29" \
  CONSUL_VERSION="0.9.0" \
  CONSUL_URL="https://releases.hashicorp.com/consul" \
  APK_ADD="ca-certificates curl unzip"

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

LABEL \
  version="1707-30" \
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
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk --no-cache update && \
  apk --no-cache upgrade && \
  apk --no-cache add ${APK_ADD} && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --cacert /etc/ssl/certs/ca-certificates.crt \
    --output /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip \
    "${CONSUL_URL}/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" && \
  unzip /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip -d /bin/ && \
  apk --purge del ${APK_ADD} && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

VOLUME [ "/data" ]

ENTRYPOINT [ "/bin/consul" ]

CMD [ "agent", "-data-dir", "/data" ]

# ---------------------------------------------------------------------------------------
