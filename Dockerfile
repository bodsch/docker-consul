
FROM golang:1-alpine as builder

ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_TYPE
ARG CONSUL_VERSION

ENV \
  TERM=xterm \
  GOPATH=/opt/go \
  GOOS=linux \
  GOARCH=amd64 \
  GOMAXPROCS=4

# ---------------------------------------------------------------------------------------

RUN \
  echo "export BUILD_DATE=${BUILD_DATE}"           > /etc/profile.d/consul.sh && \
  echo "export BUILD_TYPE=${BUILD_TYPE}"          >> /etc/profile.d/consul.sh && \
  echo "export CONSUL_VERSION=${CONSUL_VERSION}"  >> /etc/profile.d/consul.sh

# hadolint ignore=DL3017,DL3018
RUN \
  apk update  --quiet --no-cache && \
  apk upgrade --quiet --no-cache && \
  apk add     --quiet --no-cache \
    bash git ncurses make zip

WORKDIR /opt/go

RUN \
  go get github.com/hashicorp/consul

WORKDIR /opt/go/src/github.com/hashicorp/consul

RUN \
  if [ "${BUILD_TYPE}" == "stable" ] ; then \
    echo "switch to stable Tag v${CONSUL_VERSION}" && \
    git checkout "tags/v${CONSUL_VERSION}" 2> /dev/null ; \
  fi

RUN \
  export PATH="${GOPATH}/bin:${PATH}" && \
  make linux

RUN \
  mkdir /etc/consul.d && \
  cp -a   bin/consul /usr/bin/ && \
  cp -ar  bench/conf/*.json  /etc/consul.d/

# ---------------------------------------------------------------------------------------

FROM alpine:3.9

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

COPY --from=builder /etc/profile.d/consul.sh  /etc/profile.d/consul.sh
COPY --from=builder /usr/bin/consul           /usr/bin/consul
COPY --from=builder /etc/consul.d             /etc/consul.d

VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/consul"]

CMD ["agent", "-data-dir", "/data"]

# ---------------------------------------------------------------------------------------

LABEL \
  version="${BUILD_VERSION}" \
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
