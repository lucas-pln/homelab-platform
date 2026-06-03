# Homelab Platform

Personal Proxmox homelab for building reusable AlmaLinux 9 templates and cloning disposable virtual machines.

Current workflow:

```text
dnsmasq DNS/DHCP
  → Packer
  → Kickstart
  → template package install and cleanup
  → Proxmox template
  → Terraform clone
  → cloud-init first boot
  → Ansible validation
```

This repository tracks a small Proxmox automation workflow: build an AlmaLinux template, clone a VM, configure first boot, and validate the result.

## How To Read This Repo

This is a homelab portfolio project, so the repository is organized around clear ownership boundaries rather than a single all-in-one automation script:

- Packer builds the reusable AlmaLinux 9 Proxmox template.
- Kickstart performs the unattended OS installation during the Packer build.
- Packer shell provisioners add template integration packages, write an embedded build manifest, and clean build-time state.
- Terraform clones one disposable VM from the template and attaches cloud-init user-data.
- cloud-init handles first-boot identity, user access, and SSH policy inside the cloned VM.
- Ansible currently validates connectivity and first-boot clone state; it does not yet apply a post-provisioning baseline role.
- CI runs static validation for Packer, shell scripts, and Terraform. It does not run a live Proxmox build.

## Current State

| Component | State | Notes |
|---|---|---|
| DNS/DHCP | Implemented manually | `dnsmasq` provides lab DNS and DHCP leases |
| Image build | Implemented | Packer builds an AlmaLinux 9 VM on Proxmox |
| OS installation | Implemented | Kickstart automates the AlmaLinux install |
| Template cleanup | Implemented | Bash provisioners install template packages, write an embedded build manifest, and finalize the image before template conversion |
| VM provisioning | Implemented | Terraform creates one full disposable VM clone with generated naming, tags, and cloud-init user-data |
| First boot config | Implemented | cloud-init sets hostname, FQDN, `ansible` user access, SSH key, and root/SSH password policy |
| Ansible tooling | Implemented | Execution environment, Proxmox dynamic inventory, connectivity validation, and clone validation exist |
| Ansible baseline | Not implemented yet | Planned for post-provisioning config and hardening |
| CI validation | Implemented | GitHub Actions runs Packer, ShellCheck, and Terraform validation checks |
| IPAM/DNS automation | Not implemented yet | DNS records are still handled manually |
| Backup/recovery validation | Not implemented yet | Planned after the provisioning path is stable |

## What Works Today

The current repo can:

- build an AlmaLinux 9 Proxmox template with Packer
- automate the minimal OS install with Kickstart
- use DHCP during the image build
- install `qemu-guest-agent` and `cloud-init` in the template
- write an embedded build manifest to `/etc/template-build-manifest.json`
- produce local checksum and manifest artifacts under `artifacts/`
- clean the VM before converting it into a reusable template
- clone one full disposable VM from that template with Terraform
- upload and attach cloud-init user-data
- apply first-boot identity, `ansible` user access, SSH key, and login policy with cloud-init
- tag Terraform-created VMs for Ansible inventory discovery
- provide a Proxmox-backed Ansible dynamic inventory
- validate managed host connectivity with Ansible
- validate first-boot identity, cloud-init completion, hostname/FQDN, and IPv4 DNS resolution before baseline configuration
- run CI checks for Packer, shell scripts, and Terraform

## Architecture

The lab uses a small set of infrastructure nodes:

| Node | Role |
|---|---|
| Lab gateway | Provides NAT/routing for the isolated lab network |
| DNS/DHCP node | Provides internal DNS and DHCP with dnsmasq |
| Control node | Runs Git, Packer, Terraform, and Ansible automation |
| Proxmox node | Hosts templates and disposable VMs |
| Disposable VMs | Cloned from the AlmaLinux 9 template through Terraform |

Example lab addressing:

| Purpose | Address |
|---|---:|
| Lab gateway | `10.10.10.1` |
| DNS/DHCP node | `10.10.10.53` |
| Control node | `10.10.10.10` |
| Proxmox node | `10.10.10.20` |
| DHCP range | `10.10.10.100-199` |

## Provisioning Flow

```text
1. Packer creates a temporary VM on Proxmox.
2. The VM receives a DHCP lease from dnsmasq.
3. The AlmaLinux installer downloads the Kickstart file over temporary HTTP.
4. Kickstart installs the AlmaLinux minimal environment.
5. Packer validates root SSH access.
6. Packer installs template integration packages.
7. Packer writes `/etc/template-build-manifest.json` inside the image.
8. Packer finalizes the image by cleaning build-time state before template conversion.
9. Packer writes local checksum and manifest artifacts under `artifacts/`.
10. The VM is converted into a reusable Proxmox template.
11. Terraform creates one full disposable VM clone from the template.
12. Terraform uploads and attaches a cloud-init user-data snippet.
13. cloud-init applies first-boot identity, access, and SSH policy.
14. Ansible dynamic inventory discovers Terraform-managed running VMs by Proxmox tags.
15. Ansible validates clone state before baseline configuration.
```

Ansible currently handles inventory, connectivity checks, and clone validation. A baseline configuration role is not implemented yet.

## Repository Layout

```text
.
├── ansible/              # Execution environment, inventory, and validation playbooks
├── packer/
│   └── almalinux9/       # AlmaLinux 9 Proxmox template build
├── terraform/            # Proxmox VM provisioning
├── .env.example          # Example local environment variables
├── .envrc                # direnv loader
├── .gitignore
└── README.md
```

## Next Work

- add an Ansible baseline role for common Linux configuration
- expand clone validation as new template guarantees are added
- improve credential handling documentation
- improve least-privilege Proxmox automation
- support multiple disposable VMs using `count` or `for_each`
- manage DNS records through Terraform or IPAM integration
