FROM debian:bookworm-slim AS build

LABEL org.opencontainers.image.url="https://github.com/misotolar/docker-ipxe-builder"
LABEL org.opencontainers.image.description="Custom iPXE firmware build container"
LABEL org.opencontainers.image.authors="Michal Sotolar <michal@sotolar.com>"

ARG VERSION=5783a10f721d8f10d535dd2f69a9382c5ef7be7b
ARG SHA256=a116373623d7d89ef8402cc427f6d8e912fa3186ba9c2003db8f5c1366356ae1
ADD https://github.com/ipxe/ipxe/archive/$VERSION.tar.gz /tmp/ipxe.tar.gz

ARG WIMBOOT_VERSION=2.8.0
ARG WIMBOOT_SHA256=74d4bf3d09386ccbbe907d9db59030f8cd8c88f7b4ccb799d386f31def11b3fe
ADD https://github.com/ipxe/wimboot/releases/download/v$WIMBOOT_VERSION/wimboot /build/wimboot/wimboot

ENV PRODUCT_NAME ""
ENV PRODUCT_SHORT_NAME ""
ENV PRODUCT_URI https://ipxe.org
ENV PRODUCT_TAG_LINE "Open Source Network Boot Firmware"

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
    echo "$WIMBOOT_SHA256 */build/wimboot/wimboot" | sha256sum -c -; \
    tar xf /tmp/ipxe.tar.gz --strip-components=1; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY resources/builder.sh /usr/local/bin/builder.sh

WORKDIR /build/ipxe/src

ENTRYPOINT ["builder.sh"]
CMD ["/dest"]
