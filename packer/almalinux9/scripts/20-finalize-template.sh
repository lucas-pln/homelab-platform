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
  dnf clean all
  rm -rf /var/cache/dnf/*
  ok "Cleaned package manager cache"

  find /tmp /var/tmp -mindepth 1 -exec rm -rf {} +
  ok "Cleaned temporary files"

  rm -f /root/anaconda-ks.cfg
  rm -f /root/original-ks.cfg
  ok "Removed installer/build logs"

  cloud-init clean --logs --seed
  ok "Cleaned cloud-init state"

  truncate -s 0 /etc/machine-id

  if [ -d /var/lib/dbus ]; then
    rm -f /var/lib/dbus/machine-id
    ln -s /etc/machine-id /var/lib/dbus/machine-id
  fi

  rm -f /var/lib/systemd/random-seed
  ok "Reset machine identity"

  rm -f /etc/ssh/ssh_host_*_key
  rm -f /etc/ssh/ssh_host_*_key.pub
  ok "Removed SSH host keys"

  rm -rf /root/.ssh
  ok "Removed root SSH directory"

  rm -f /etc/sudoers.d/packer
  ok "Removed temporary packer sudo access"

  if getent passwd packer >/dev/null 2>&1; then
    userdel -r -f packer
  fi

  if getent passwd packer >/dev/null 2>&1; then
    fail "packer user still exists after userdel"
  fi
  ok "Removed packer user"

  ok "Cleanup completed"
}

log_cleanup() {
  journalctl --rotate --vacuum-size=0
  find /var/log -type f -exec truncate -s 0 {} +
  ok "Cleaned system logs"

  rm -f /root/.wget-hsts
  rm -f /root/.bash_history

  unset HISTFILE
  history -c || true
  ok "Cleaned shell and download history"
}

template_validation() {
  [[ -z "$(find /var/cache/dnf -mindepth 1 -print -quit)" ]] || fail "Package manager cache still contains files"
  ok "Validated package manager cache is empty"

  [[ -z "$(find /tmp -mindepth 1 -print -quit)" ]] || fail "/tmp still contains files"
  [[ -z "$(find /var/tmp -mindepth 1 -print -quit)" ]] || fail "/var/tmp still contains files"
  ok "Validated temporary directories are empty"

  [[ ! -f /root/anaconda-ks.cfg ]] || fail "/root/anaconda-ks.cfg is still present"
  [[ ! -f /root/original-ks.cfg ]] || fail "/root/original-ks.cfg is still present"
  ok "Validated installer/build logs are removed"

  [[ ! -d /root/.ssh ]] || fail "/root/.ssh is still present"
  ok "Validated root SSH directory is removed"

  [[ -z "$(find /var/lib/cloud -mindepth 1 -print -quit)" ]] || fail "/var/lib/cloud still contains cloud-init state"
  ok "Validated cloud-init state is clean"

  [[ -f /etc/machine-id ]] || fail "/etc/machine-id is missing"
  [[ ! -s /etc/machine-id ]] || fail "/etc/machine-id is not empty"
  if [[ -d /var/lib/dbus ]]; then
    [[ -L /var/lib/dbus/machine-id ]] || fail "/var/lib/dbus/machine-id is not a symbolic link"
  fi
  [[ ! -f /var/lib/systemd/random-seed ]] || fail "/var/lib/systemd/random-seed is still present"
  ok "Validated machine identity is reset"

  [[ -z "$(find /etc/ssh -maxdepth 1 -name 'ssh_host_*_key' -print -quit)" ]] || fail "SSH private host keys are still present"
  [[ -z "$(find /etc/ssh -maxdepth 1 -name 'ssh_host_*_key.pub' -print -quit)" ]] || fail "SSH public host keys are still present"
  ok "Validated SSH host keys are removed"

  [[ -z "$(find /var/log -type f -size +0c -print -quit)" ]] || fail "/var/log contains non-empty log files"
  ok "Validated system logs are empty"

  [[ ! -f /root/.wget-hsts ]] || fail "/root/.wget-hsts is still present"
  [[ ! -f /root/.bash_history ]] || fail "/root/.bash_history is still present"
  ok "Validated shell and download history are removed"

  if getent passwd packer >/dev/null 2>&1; then
    fail "packer user still exists"
  fi
  ok "Validated Packer user deletion"

  [[ ! -e /etc/sudoers.d/packer ]] || fail "/etc/sudoers.d/packer still exists"
  ok "Validated Packer sudoers file deletion"

  [[ ! -d /home/packer ]] || fail "/home/packer still exists"
  ok "Validated Packer home dir deletion"

  ok "Template validated"
}

main() {
  template_cleanup
  log_cleanup
  template_validation

  sync
  systemctl poweroff
}

main "$@"
