# Homelab Platform

Personal Proxmox homelab for building reusable AlmaLinux 9 templates and cloning disposable virtual machines.

Current workflow:

```text
dnsmasq DNS/DHCP
  → Packer
  → Kickstart
  → template cleanup
  → Proxmox template
  → Terraform clone
  → cloud-init first boot
```

This repository tracks the build-out of a small infrastructure automation workflow. The focus is on reproducible VM builds, clean template cloning, first-boot identity, configuration management, validation, and recovery.

## Current State

| Component | State | Notes |
|---|---|---|
| DNS/DHCP | Implemented manually | `dnsmasq` provides lab DNS and DHCP leases |
| Image build | Implemented | Packer builds an AlmaLinux 9 VM on Proxmox |
| OS installation | Implemented | Kickstart automates the AlmaLinux install |
| Template cleanup | Implemented | Bash scripts prepare the image before template conversion |
| VM provisioning | Implemented | Terraform clones one disposable VM pattern |
| First boot config | Implemented | cloud-init sets hostname, FQDN, user access and SSH key|
| Ansible tooling | Partially implemented | Execution environment, Proxmox dynamic inventory, and ping validation exist |
| Ansible baseline | Not implemented yet | Planned for post-provisioning config and hardening |
| CI validation | Implemented | GitHub Actions runs Packer, ShellCheck, and Terraform validation checks |
| IPAM/DNS automation | Not implemented yet | DNS records are still handled manually |
| Backup/recovery validation | Not implemented yet | Planned after the provisioning path is stable |
| Monitoring/logging | Not implemented yet | Future scope |

## What Works Today

The current repo can:

- build an AlmaLinux 9 Proxmox template with Packer
- automate the OS install with Kickstart
- use DHCP during the image build
- install `qemu-guest-agent` and `cloud-init` in the template
- clean the VM before converting it into a reusable template
- clone a disposable VM from that template with Terraform
- upload and attach cloud-init user-data
- apply first-boot identity and access settings with cloud-init
- provide a Proxmox-backed Ansible dynamic inventory and ping validation playbook
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
4. Kickstart installs the OS and baseline packages.
5. Packer validates SSH access.
6. Packer runs update and cleanup scripts.
7. The VM is converted into a reusable Proxmox template.
8. Terraform clones a disposable VM from the template.
9. Terraform uploads and attaches a cloud-init user-data snippet.
10. cloud-init applies first-boot identity and access settings.
```

Ansible tooling exists for inventory and connectivity validation. A baseline role for post-provisioning configuration and hardening is still planned.

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

Short term:

- add an Ansible baseline role for common Linux configuration
- add post-provisioning validation
- expand CI coverage as new automation is added
- improve credential handling documentation

Later:

- manage DNS records through Terraform or IPAM integration
- support multiple disposable VMs using `count` or `for_each`
- introduce identity and access management patterns
- add backup and recovery validation
- add monitoring with Prometheus and Grafana
- add centralized logging
- improve least-privilege Proxmox automation
