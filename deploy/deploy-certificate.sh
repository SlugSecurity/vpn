#!/bin/sh
set -eu

: "${LEGO_HOOK_CERT_PATH:?Set LEGO_HOOK_CERT_PATH}"
: "${LEGO_HOOK_CERT_KEY_PATH:?Set LEGO_HOOK_CERT_KEY_PATH}"

cert_tmp="$(mktemp /certs/.tls.crt.XXXXXX)"
key_tmp="$(mktemp /certs/.tls.key.XXXXXX)"

cleanup() {
    if [ -n "${cert_tmp:-}" ]; then
        rm -f "$cert_tmp"
    fi

    if [ -n "${key_tmp:-}" ]; then
        rm -f "$key_tmp"
    fi
}

trap cleanup EXIT HUP INT TERM

cp "$LEGO_HOOK_CERT_PATH" "$cert_tmp"
cp "$LEGO_HOOK_CERT_KEY_PATH" "$key_tmp"
chown 1000:1000 /certs "$cert_tmp" "$key_tmp"
chmod 750 /certs
chmod 644 "$cert_tmp"
chmod 600 "$key_tmp"

mv -f "$key_tmp" /certs/tls.key
key_tmp=""

mv -f "$cert_tmp" /certs/tls.crt
cert_tmp=""
