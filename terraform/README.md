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
- cloud-init attachment
- VM startup after provisioning

It currently provisions one disposable VM.

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
- existing AlmaLinux 9 Proxmox template
- Proxmox API token loaded through environment variables
- SSH access to the Proxmox node for provider file/snippet operations

## Authentication

Credentials are not stored in Terraform files.

The Proxmox API token is expected to come from the local shell environment, here loaded with `.env` and `direnv`.

Example:

```bash
export PROXMOX_VE_API_TOKEN="user@realm!token-name=token-secret"
```

/!\ Do not commit real API tokens, SSH keys, or `.env` files.

## cloud-init

Terraform renders this template:

```text
terraform/cloud-init/user-data.yaml.tftpl
```

The rendered user-data is attached to the cloned VM and handles first-boot configuration:

- hostname
- FQDN
- user creation
- SSH authorized key injection
- DHCP hostname refresh through NetworkManager connection reactivation

The DHCP refresh exists because cloned VM may receive a DHCP lease before its final hostname is fully applied.
After cloud-init sets the hostname, it brings the guest network connection back up so the next DHCP request can include the final hostname for DHCP/DNS registration.

## Proxmox SSH Access

This lab currently uses SSH access to the Proxmox node for provider-side file/snippet operations.

Planned improvements:

- use a dedicated automation user
- restrict SSH key usage
- limit access to the control node
- use scoped Proxmox API tokens
- document the required Proxmox privileges

## Current Limitations

- assumes the Proxmox template already exists
- workflow works only for one disposable VM
- does not manage DNS records yet
- does not generate Ansible inventory yet
- does not include CI validation yet
- does not fully implement least-privilege Proxmox access yet

## Next Work

- add an SSH target output for the Ansible user
- add CI checks for Terraform formatting and validation
- document or generate the Ansible inventory handoff

Later:

- support more than one disposable VM per apply
- integrate DNS/IPAM instead of relying only on DHCP registration
- separate reusable defaults from local lab values
- replace root SSH access with a restricted Proxmox automation user
