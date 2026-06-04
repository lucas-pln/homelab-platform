# Terraform Proxmox VM Provisioning

Terraform configuration for cloning disposable AlmaLinux 9 virtual machines on Proxmox.

This directory assumes the AlmaLinux 9 template already exists. The template is built separately with Packer and Kickstart.

```text
Packer-built Proxmox template → Terraform clone → cloud-init first boot
```

## Current State

This configuration currently handles:

- disposable VM name generation
- cloud-init user-data rendering
- Proxmox snippet upload
- VM cloning from an existing AlmaLinux 9 template
- CPU, memory, disk, network, BIOS, and guest-agent settings
- configurable additional VM data disk
- cloud-init attachment
- VM startup after provisioning
- Proxmox tags for Ansible dynamic inventory discovery
- VM FQDN, IPv4 address, and tag outputs

It currently provisions one full-clone disposable VM.

Provider versions are pinned in `versions.tf`:

- `bpg/proxmox` `0.106.0`
- `hashicorp/random` `3.9.0`

## Files

```text
terraform/
├── cloud-init/
│   └── user-data.yaml.tftpl
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
└── README.md
```

## Requirements

- Terraform installed on the control node
- Proxmox VE reachable from the control node
- Proxmox VE API certificate trusted by the control node
- existing AlmaLinux 9 Proxmox template
- Proxmox API token loaded through environment variables
- SSH access to the Proxmox node for provider file/snippet operations

## Authentication

Credentials are not stored in Terraform files.

The Proxmox API token is expected to come from the local shell environment, here loaded with `.env` and `direnv`.

Example:

```bash
export PROXMOX_VE_ENDPOINT="https://your-proxmox-node:8006/"
export PROXMOX_VE_API_TOKEN="user@realm!token-name=token-secret"
```

Terraform validates the Proxmox API TLS certificate. The endpoint hostname must match the certificate, and the control node must trust the issuing CA.

/!\ Do not commit real API tokens, SSH keys, or `.env` files.

## cloud-init

Terraform renders this template:

```text
terraform/cloud-init/user-data.yaml.tftpl
```

The rendered user-data is attached to the cloned VM and handles first-boot configuration:

- hostname
- FQDN
- `ansible` user creation with passwordless sudo
- SSH authorized key injection for the `ansible` user
- root login disablement
- SSH password authentication disablement
- NetworkManager refresh for the `enp6s18` DHCP lease

The DHCP refresh exists because cloned VM may receive a DHCP lease before its final hostname is fully applied.
After cloud-init sets the hostname, it brings the guest network connection back up so the next DHCP request can include the final hostname for DHCP/DNS registration.

## Ansible Handoff

Terraform tags the cloned VM with `managed_by_terraform`, `os_almalinux9`, and `env_lab` so the Proxmox dynamic inventory can place it in the `terraform_managed`, `almalinux9`, and `lab` groups.

After provisioning, Ansible can run clone validation against that group before applying any baseline configuration.

## Proxmox SSH Access

Terraform uses SSH to the Proxmox node for file/snippet operations. It currently authenticates as `root` through the SSH agent.

Planned improvements:

- use a dedicated automation user
- restrict SSH key usage
- limit access to the control node
- use scoped Proxmox API tokens
- document the required Proxmox privileges
- document Proxmox API certificate trust setup

## Current Limitations

- assumes the Proxmox template already exists
- workflow works only for one disposable VM
- does not manage DNS records yet
- does not fully implement least-privilege Proxmox access yet

## Next Work

Later:

- support more than one disposable VM per apply
- integrate DNS/IPAM instead of relying only on DHCP registration
- separate reusable defaults from local lab values
- replace root SSH access with a restricted Proxmox automation user
