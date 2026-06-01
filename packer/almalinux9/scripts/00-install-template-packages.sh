#!/usr/bin/env bash
set -euo pipefail

ok() {
    echo "[OK] $*"
}

fail() {
    echo "[FAILED] $*" >&2
    exit 1
}

echo '[Provision] Install template packages'
dnf install -y \
        qemu-guest-agent \
        cloud-init

echo '[Provision] Enable Proxmox guest agent'
systemctl enable --now qemu-guest-agent

echo '[Provision] Enable cloud-init service'
systemctl enable cloud-init

echo '[Provision] Validate Proxmox'
rpm -q qemu-guest-agent >/dev/null || fail "qemu-guest-agent is missing"
systemctl is-enabled --quiet qemu-guest-agent || fail "qemu-guest-agent is not enabled"

echo '[Provision] Validate cloud-init'
rpm -q cloud-init >/dev/null || fail "cloud-init is missing"
[[ ! -f /etc/cloud/cloud-init.disabled ]] || fail "cloud-init is disabled"

ok "template packages installed successfully"