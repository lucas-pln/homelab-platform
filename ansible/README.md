# Ansible MVP

This directory contains the current Ansible MVP for the homelab platform.

The implemented scope is inventory, execution environment configuration, and basic connectivity validation. It does not yet include a baseline role for post-provisioning configuration or hardening.

## Current State

This directory currently provides:

- Ansible configuration in `ansible.cfg`
- `ansible-navigator` configuration in `ansible-navigator.yml`
- a Podman-based execution environment definition
- pinned Galaxy collections and Python dependencies
- Proxmox dynamic inventory using `community.proxmox.proxmox`
- a `ping.yml` playbook for validating managed host connectivity

## Authentication

The Proxmox dynamic inventory reads credentials from environment variables:

```bash
PROXMOX_ANSIBLE_PROXMOX_URL
PROXMOX_ANSIBLE_USER
PROXMOX_ANSIBLE_TOKEN_ID
PROXMOX_ANSIBLE_TOKEN_SECRET
```

Do not commit real Proxmox credentials, API tokens, SSH keys, or generated artifacts.

## Current Limitations

- no baseline role is implemented yet
- inventory depends on Proxmox API access
- host targeting currently comes from Proxmox inventory data
- host key checking is disabled for the MVP

## Next Work

- add a common Linux baseline role
- add post-provisioning validation beyond ping
- document the expected execution environment build/run workflow
