FROM alpine:latest@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412 AS builder

ARG ARCH="amd64"
ARG REPO="userdocs/iperf3-static"

# Add metadata labels for easy parsing
LABEL org.opencontainers.image.base.name="alpine:latest" \
      org.opencontainers.image.base.id="alpine" \
      org.opencontainers.image.base.codename="latest" \
      org.opencontainers.image.title="iperf3-static" \
      org.opencontainers.image.description="statically linked iperf3 linux binaries built on Alpine Linux" \
      org.opencontainers.image.source="https://github.com/userdocs/iperf3-static" \
      org.opencontainers.image.url="https://github.com/userdocs/iperf3-static" \
      org.opencontainers.image.documentation="https://github.com/userdocs/iperf3-static/blob/master/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="userdocs"

RUN apk update \
	&& apk upgrade \
	&& apk add sudo \
	&& adduser -Ds /bin/bash -u 1000 username \
	&& printf '%s' 'username ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/github

ADD --chown=username:username --chmod=700 "https://github.com/${REPO}/releases/latest/download/iperf3-${ARCH}" /usr/local/bin/iperf3

USER username

WORKDIR /home/username
