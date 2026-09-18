FROM alpine:latest@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6 AS builder

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
