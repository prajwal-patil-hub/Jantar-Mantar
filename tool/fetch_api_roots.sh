#!/usr/bin/env bash
# Generate the TLS pin bundle for the API host (see SECURITY.md → Certificate
# pinning, and app/lib/core/security/certificate_pinning.dart).
#
#   ./tool/fetch_api_roots.sh orsqjucexvrefmexztay.supabase.co
#
# RUN THIS FROM A TRUSTED NETWORK. Behind a corporate VPN, a captive portal, a
# CI sandbox or any intercepting proxy you will capture THAT proxy's CA and pin
# it — which is strictly worse than not pinning at all. The script refuses to
# write a bundle whose root looks like an interception CA, but that check is a
# safety net, not a substitute for knowing where you are.
#
# Verify the printed root against the CA's own published fingerprint before
# committing the bundle.
set -euo pipefail

HOST="${1:?usage: fetch_api_roots.sh <host>}"
OUT="app/assets/certs/api_roots.pem"

command -v openssl >/dev/null || { echo "openssl is required"; exit 1; }

echo "Fetching the certificate chain for ${HOST}…"
CHAIN="$(echo | openssl s_client -connect "${HOST}:443" \
  -servername "${HOST}" -showcerts 2>/dev/null)"

echo
echo "Chain as presented:"
echo "${CHAIN}" | grep -E '^ *[0-9]+ s:|^ *[0-9]+ i:'
echo

# Refuse the obvious interception cases rather than silently pinning a proxy.
if echo "${CHAIN}" | grep -qiE 'egress|mitm|interception|proxy|zscaler|netskope'; then
  echo "REFUSING: the chain looks like an intercepting proxy, not the real CA."
  echo "Re-run this from a trusted network."
  exit 2
fi

# The last certificate in the chain is the highest one the server sends. Pin
# the ROOT, so leaf and intermediate rotation does not break the app.
mkdir -p "$(dirname "${OUT}")"
echo "${CHAIN}" \
  | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' \
  | awk 'BEGIN{c=0} /BEGIN CERT/{c++} {print > ("/tmp/pin_cert_" c ".pem")}'

LAST="$(ls -1 /tmp/pin_cert_*.pem | sort -V | tail -1)"
echo "Root being pinned:"
openssl x509 -in "${LAST}" -noout -subject -issuer -enddate -fingerprint -sha256

cp "${LAST}" "${OUT}"
rm -f /tmp/pin_cert_*.pem
echo
echo "Wrote ${OUT}."
echo "Next: verify the SHA-256 above against the CA's published value, add"
echo "  assets/certs/"
echo "to the flutter: assets: list in app/pubspec.yaml, and ship a backup root"
echo "alongside it so a CA rotation does not require an emergency release."
