#!/usr/bin/env bash
set -euo pipefail

ok() {
  echo "[OK] $*"
}

fail() {
  echo "[FAILED] $*" >&2
  exit 1
}

: "${TEMPLATE_OS:?TEMPLATE_OS is required}"
: "${TEMPLATE_MAJOR_VERSION:?TEMPLATE_MAJOR_VERSION is required}"
: "${TEMPLATE_ROLE:?TEMPLATE_ROLE is required}"
: "${ISO_CHECKSUM:?ISO_CHECKSUM is required}"

echo "[META] Write embedded build manifest" 
cat >/etc/template-build-manifest.json <<EOF
{
  "os": "$TEMPLATE_OS",
  "major_version": "$TEMPLATE_MAJOR_VERSION",
  "build_tool": "packer",
  "template_role": "$TEMPLATE_ROLE",
  "iso_checksum": "$ISO_CHECKSUM",
  "build_date_utc": "$(date -u +'%FT%TZ')"
}
EOF

echo "[META] Validate embedded build manifest is present"
[[ -s /etc/template-build-manifest.json ]] || fail "Embedded template-build-manifest.json is missing or is empty"

ok "Embedded build manifest created successfully"