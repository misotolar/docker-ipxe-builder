#!/bin/bash

set -ex

sed -i "/COLOR_[A-Z]*_BG/s/COLOR_BLUE/COLOR_BLACK/" config/colour.h
sed -i "/OCSP_CHECK/c #undef OCSP_CHECK" config/crypto.h
sed -i "/DOWNLOAD_PROTO_HTTPS/c #define DOWNLOAD_PROTO_HTTPS" config/general.h
sed -i "/CRYPTO_80211_/s/^#define/#undef/" config/general.h
sed -i "/IWMGMT_CMD/c #undef IWMGMT_CMD" config/general.h
sed -i "/REBOOT_CMD/c #define REBOOT_CMD" config/general.h
sed -i "/POWEROFF_CMD/c #define POWEROFF_CMD" config/general.h
sed -i "/IMAGE_TRUST_CMD/c #define IMAGE_TRUST_CMD" config/general.h
sed -i "/NTP_CMD/c #define NTP_CMD" config/general.h
sed -i "/PING_CMD/c #define PING_CMD" config/general.h

_options=()

if [ ! -z "$DEBUG_BUILD" ]; then
    _options+=("DEBUG=$DEBUG_BUILD")
fi

if [ -f "$1/embed.ipxe" ]; then
    _options+=("EMBED=$1/embed.ipxe")
fi

_options+=(
    bin/ipxe.lkrn
    bin/undionly.kpxe
    bin-x86_64-efi/ipxe.efi
)

make "${_options[@]}"

util/genfsimg -o bin/ipxe.iso \
    bin-x86_64-efi/ipxe.efi \
    bin/ipxe.lkrn

mkdir -p "$1"
cp -av bin/ipxe.iso "$1"/ipxe.iso
cp -av bin/ipxe.lkrn "$1"/ipxe.lkrn
cp -av bin/undionly.kpxe "$1"/undionly.kpxe
cp -av bin-x86_64-efi/ipxe.efi "$1"/efi-x86_64.efi
cp -av /build/wimboot/wimboot "$1"/wimboot
