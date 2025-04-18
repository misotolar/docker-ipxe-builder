FROM debian:bookworm-slim AS build

LABEL maintainer="michal@sotolar.com"

ARG VERSION=0a48bb32145ce14b11d5d1e2a537d3d567489385
ARG SHA256=83e62b1f6439ea63f4af54471943b647823e06b2d139edd18da33fe6b1dcad11
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
