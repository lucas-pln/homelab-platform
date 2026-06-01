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

echo "[META] Write template metadata" 
cat >/etc/template-build.json <<EOF
{
  "os": "$TEMPLATE_OS",
  "major_version": "$TEMPLATE_MAJOR_VERSION",
  "build_tool": "packer",
  "template_role": "$TEMPLATE_ROLE",
  "iso_checksum": "$ISO_CHECKSUM",
  "build_date_utc": "$(date -u +%F)"
}
EOF

echo "[META] Validate template metadata is present"
[[ -s /etc/template-build.json ]] || fail "template-build.json is missing or is empty"

ok "template metadata file created successfully"