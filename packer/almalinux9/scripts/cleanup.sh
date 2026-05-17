#!/bin/bash
set -euo pipefail


echo "[Cleanup] Cleaning package manager cache"

dnf clean all
rm -rf /var/cache/dnf/*

echo "[Cleanup] Cleaning temporary files"

rm -rf /tmp*
rm -rf /var/tmp/*

echo "[Cleanup] Cleaning installer/build logs"

rm -f /root/ks-post.log
rm -f /root/anaconda-ks.cfg

echo "[Cleanup] Cleaning shell and download history"

rm -f /root/.wget-hsts
rm -f /root/.bash_history
rm -f /home/packer/.wget-hsts || true
rm -f /home/packer/.bash_history || true

echo "[Cleanup] Cleaning system logs"

find /var/log -type f -exec truncate -s 0 {} \; || true
journalctl --rotate || true
journalctl --vacuum-time=1s || true

echo "[Cleanup] Cleaning cloud-init state"

cloud-init clean --logs --seed || true
rm -rf /var/lib/cloud/instances/*
rm -rf /var/lib/cloud/instance

echo "[Cleanup] Resetting machine identity"

truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
rm -f /var/lib/systemd/random-seed

echo "[Cleanup] Removing SSH host keys"

rm -f /etc/ssh/ssh_host_*key*

echo "[Cleanup] Removing temporary Packer access"

rm -f /etc/sudoers.d/packer
rm -rf /home/packer/.ssh || true
passwd -l packer || true
usermod -s /sbin/nologin packer || true

echo "[Cleanup] Cleanup completed"