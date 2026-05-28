# Ansible Automation

This directory contains the Ansible automation for the homelab platform.

The implemented scope is execution environment configuration, Proxmox dynamic inventory, connectivity validation, and pre-baseline template clone validation. It does not yet include a baseline role for post-provisioning configuration or hardening.

## Current State

This directory currently provides:

- Ansible configuration in `ansible.cfg`
- `ansible-navigator` configuration in `ansible-navigator.yml`
- a Podman-based execution environment definition
- pinned Galaxy collections and Python dependencies
- Proxmox dynamic inventory using `community.proxmox.proxmox`
- a `ping.yml` playbook for validating managed host connectivity
- a `template-validate.yml` playbook for validating newly provisioned template clones before baseline configuration

## Playbooks

| Playbook | Purpose |
|---|---|
| `playbooks/ping.yml` | Validates basic Ansible connectivity to managed hosts |
| `playbooks/template-validate.yml` | Validates newly provisioned template clones before baseline configuration |

## Template Validation

`template-validate.yml` runs against the `terraform_managed` inventory group after Terraform provisioning and before baseline configuration.

It validates:

- temporary Packer access is disabled
- Packer build artifacts are absent
- machine identity was regenerated on first boot
- cloud-init completed successfully
- hostname and FQDN are applied
- FQDN resolves to the VM IPv4 address
- default IPv4 route is present

The playbook writes a local report under:

```text
artifacts/template-validate/
```

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
- expand template validation as new template guarantees are added
- document the expected execution environment build/run workflow
