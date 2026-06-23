FROM debian:trixie-slim AS build

LABEL org.opencontainers.image.url="https://github.com/misotolar/docker-ipxe-builder"
LABEL org.opencontainers.image.description="Custom iPXE firmware build container"
LABEL org.opencontainers.image.authors="Michal Sotolar <michal@sotolar.com>"

ENV IPXE_VERSION=2.0.0
ARG SHA256=9ed6d029be901a0ccc87cb2e5f9c774620f30f84ebdd507c6dd3e1e6229b7bd5
ADD https://github.com/ipxe/ipxe/archive/refs/tags/v$IPXE_VERSION.tar.gz /tmp/ipxe.tar.gz

ARG WIMBOOT_VERSION=2.9.0
ARG WIMBOOT_SHA256=5f067ccdc4d084d5bf77b6c853bd0f8402dfc2b4cd1b103d358993ae97fae8e3
ADD https://github.com/ipxe/wimboot/releases/download/v$WIMBOOT_VERSION/wimboot /build/wimboot/wimboot

ENV PRODUCT_NAME=""
ENV PRODUCT_SHORT_NAME=""
ENV PRODUCT_URI="https://ipxe.org"
ENV PRODUCT_TAG_LINE="Open Source Network Boot Firmware"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/ipxe

RUN set -ex; \
    sed -i 's/^Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        openssl \
        syslinux \
    ; \
    apt-get build-dep -y \
        ipxe \
    ; \
    echo "$SHA256 */tmp/ipxe.tar.gz" | sha256sum -c -; \
    tar xf /tmp/ipxe.tar.gz --strip-components=1; \
    echo "$WIMBOOT_SHA256 */build/wimboot/wimboot" | sha256sum -c -; \
    chmod 644 /build/wimboot/wimboot; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /build/ipxe/src

ENTRYPOINT ["entrypoint.sh"]
CMD ["/dest"]
