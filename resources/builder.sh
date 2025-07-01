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

if [ -f "$@/embed.ipxe" ]; then
    _options+=("EMBED=$@/embed.ipxe")
fi

_options+=(
    bin/ipxe.lkrn
    bin/undionly.kpxe
    bin-i386-efi/ipxe.efi
    bin-x86_64-efi/ipxe.efi
)

make "${_options[@]}"

util/genfsimg -o bin/ipxe.iso \
    bin-x86_64-efi/ipxe.efi \
    bin-i386-efi/ipxe.efi \
    bin/ipxe.lkrn

mkdir -p "$@"
cp -av bin/ipxe.iso "$@"/ipxe.iso
cp -av bin/ipxe.lkrn "$@"/ipxe.lkrn
cp -av bin/undionly.kpxe "$@"/undionly.kpxe
cp -av bin-i386-efi/ipxe.efi "$@"/efi-i386.efi
cp -av bin-x86_64-efi/ipxe.efi "$@"/efi-x86_64.efi
cp -av /build/wimboot/wimboot "$@"/wimboot
