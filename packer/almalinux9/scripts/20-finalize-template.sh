#!/usr/bin/env bash
set -euo pipefail

ok() {
  echo "[OK] $*"
}

fail() {
  echo "[FAILED] $*" >&2
  exit 1
}

template_cleanup() {
echo "[Cleanup] Clean package manager cache"
dnf clean all
rm -rf /var/cache/dnf/*

echo "[Cleanup] Clean temporary files"
find /tmp /var/tmp -mindepth 1 -exec rm -rf {} +

echo "[Cleanup] Clean installer/build logs"
rm -f /root/anaconda-ks.cfg
rm -f /root/original-ks.cfg

echo "[Cleanup] Clean cloud-init state"
cloud-init clean --logs --seed

echo "[Cleanup] Reset machine identity"
truncate -s 0 /etc/machine-id

if [ -d /var/lib/dbus ]; then
  rm -f /var/lib/dbus/machine-id
  ln -s /etc/machine-id /var/lib/dbus/machine-id
fi

rm -f /var/lib/systemd/random-seed

echo "[Cleanup] Remove SSH host keys"
rm -f /etc/ssh/ssh_host_*_key
rm -f /etc/ssh/ssh_host_*_key.pub

echo "[Cleanup] Remove temporary root access"
rm -rf /root/.ssh

echo "[Cleanup] Clean system logs"
find /var/log -type f -exec truncate -s 0 {} +
journalctl --rotate --vacuum-size=0

echo "[Cleanup] Clean shell and download history"
rm -f /root/.wget-hsts
rm -f /root/.bash_history

unset HISTFILE
history -c || true

echo "[Cleanup] Cleanup completed"
}

main() {
  template_cleanup
  #template_validation

  sync
}

main "$@"
