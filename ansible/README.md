# Ansible Automation

This directory contains the Ansible automation for the homelab platform.

The current scope is a local execution environment definition and ansible-navigator setup, a Proxmox dynamic inventory and clone validation. 

It does not include a baseline configuration role yet.

## Current State

This directory currently provides:

- Ansible configuration in `ansible.cfg`
- `ansible-navigator` configuration in `ansible-navigator.yml`
- a Podman-based execution environment definition
- pinned Galaxy collections and Python dependencies
- Proxmox dynamic inventory using `community.proxmox.proxmox`
- a `ping.yml` playbook for quick validation of managed host connectivity
- a `clone-validate.yml` playbook for validating newly provisioned clones before baseline configuration

## Playbooks

| Playbook | Purpose |
|---|---|
| `playbooks/ping.yml` | Validates basic Ansible connectivity to managed hosts |
| `playbooks/clone-validate.yml` | Validates newly provisioned clones before baseline configuration |

## Clone Validation

`clone-validate.yml` runs against the `terraform_managed` inventory group after Terraform provisioning and before baseline configuration.

It validates:

- machine identity is valid after first boot
- cloud-init completed successfully
- hostname is set and matches the inventory hostname
- FQDN is applied and starts with the hostname
- FQDN resolves to the VM default IPv4 address

The playbook writes a local report under:

```text
artifacts/validation-reports/
```

`ansible-navigator` also writes playbook artifacts under `artifacts/{playbook_name}/{time_stamp}.json`.

## Authentication

The Proxmox dynamic inventory reads credentials from environment variables:

```bash
ANSIBLE_PROXMOX_URL
ANSIBLE_PROXMOX_USER
ANSIBLE_PROXMOX_TOKEN_ID
ANSIBLE_PROXMOX_TOKEN_SECRET
```

No real Proxmox credentials, API tokens, SSH keys, or generated artifacts committed.

## Current Limitations

- no baseline role is implemented yet
- inventory depends on Proxmox API access
- host targeting currently comes from Proxmox inventory data
- host key checking is disabled for the MVP

## Next Work

- add a common Linux baseline role
- expand clone validation as new template guarantees are added
- document how to build and run the Ansible execution environment
