# Homelab Platform

This repository contains a personal infrastructure automation lab built around Proxmox, Linux, Packer, Kickstart, Bash, Terraform, cloud-init, and Ansible.

The goal is to build a small but realistic VM provisioning platform: network services provide name resolution and addressing, Packer and Kickstart build reusable Linux templates, Bash cleanup scripts prepare images for safe cloning, Terraform provisions VMs, cloud-init applies first-boot identity, and Ansible configures the operating system after deployment.

This project is both a learning lab and a portfolio project for Linux Systems Administration, SRE, and Platform Engineering roles.

## Current Focus

The Packer image build is functional and produces a reusable Proxmox template. 

The next step is to add a cleanup phase before conversion to template, so cloned VMs do not inherit temporary build artifacts.

```text
DNS/DHCP → Packer → Kickstart → [Bash cleanup] → Proxmox template
```

### What Works Today

- Static lab infrastructure nodes are defined with fixed IPs.
- A DNS/DHCP node provides internal lab name resolution and DHCP leases.
- Packer builds an AlmaLinux 9 VM template on Proxmox.
- Kickstart automates the AlmaLinux installation during the Packer build.
- The build now uses DHCP instead of a baked static installer IP.
- The template includes `qemu-guest-agent` and `cloud-init` for Proxmox integration and future first-boot customization.

### Known Gaps

- Template cleanup before conversion is still minimal.
- Post-build validation is not automated yet.
- Terraform, cloud-init, and Ansible integration are not complete yet.

## Lab Architecture

| Node | IP | Role |
|---|---:|---|
| Workstation NAT gateway | `10.10.10.1` | Temporary lab gateway provided by the Windows workstation |
| network.lab.home.arpa | `10.10.10.53` | DNS/DHCP node using dnsmasq |
| control.lab.home.arpa | `10.10.10.10` | Automation node for Git, Packer, Terraform, and Ansible |
| proxmox.lab.home.arpa | `10.10.10.20` | Proxmox virtualization host |
| DHCP range | `10.10.10.100-199` | Temporary build and disposable VMs |

## Provisioning Workflow

```text
1. Packer creates a temporary VM on Proxmox.
2. The VM receives a DHCP lease from dnsmasq.
3. The AlmaLinux installer downloads Kickstart over HTTP.
4. Kickstart installs the OS and baseline packages.
5. Packer validates SSH access.
6. A cleanup phase prepares the image for safe cloning.
7. The VM is converted into a reusable Proxmox template.
8. Terraform will later clone VMs from the template.
9. cloud-init will apply first-boot identity and access settings.
10. Ansible will configure and harden the deployed systems.
```

## Tools

| Tool | Purpose |
|---|---|
| Proxmox | Virtualization platform |
| dnsmasq | Lab DNS and DHCP |
| Packer | Builds reusable VM templates |
| Kickstart | Automates AlmaLinux installation |
| Bash | Template cleanup and helper automation scripts |
| Terraform | Provisions VMs from templates |
| cloud-init | Applies first-boot VM identity and access settings |
| Ansible | Configures and hardens systems after provisioning |
| Git | Tracks infrastructure code and documentation |

## Repository Structure

```text
.
├── ansible/
├── cloud-init/
├── docs/
├── packer/
│   └── almalinux9/
├── scripts/
├── terraform/
├── .env.example
├── .envrc
├── .gitignore
└── README.md
```

## Current Status

| Area | Status |
|---|---|
| Repository structure | In progress |
| DNS/DHCP lab services | MVP implemented manually |
| AlmaLinux 9 Packer template | Functional MVP, cleanup pending |
| Terraform provisioning | Planned |
| cloud-init customization | Planned |
| Ansible baseline | Planned |
| Monitoring | Future |
| Centralized logging | Future |
| Backup/restore testing | Future |
