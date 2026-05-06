# Homelab Platform

This repository contains my personal infrastructure automation lab.

The goal is to build a small, repeatable workflow for provisioning and configuring Linux virtual machines on Proxmox using Packer, Terraform, cloud-init, and Ansible.

The lab is a work in progress and will evolve as I add more automation and improve the structure.

## Purpose

I built this lab to improve my hands-on skills in Linux administration, infrastructure automation, and system reliability.

The idea is to keep the environment close to real operational workflows:
```text
build → deploy → configure → test → break → improve
```

## Workflow

The lab follows a simple workflow:

1. Build a reusable VM template with Packer
2. Provision virtual machines from that template with Terraform
3. Apply first-boot configuration with cloud-init
4. Configure the systems with Ansible
5. Keep the structure clean, flexible, and tracked in Git

## Tools Used

- **Proxmox** - virtualization platform
- **Packer** - builds reusable VM templates
- **Terraform** - provisions virtual machines
- **cloud-init** - handles first-boot configuration
- **Ansible** - configures the operating system and services
- **Git** - tracks the lab configuration and changes

## Repository Structure

```text
.
├── packer/
├── terraform/
├── cloud-init/
├── ansible/
├── scripts/
├── docs/
└── README.md
```

## Current Scope

The lab currently focuses on:

- Creating a clean Linux VM template
- Provisioning VMs on Proxmox
- Setting up SSH access and basic users
- Applying baseline Linux configuration with Ansible
- Keeping the workflow reproducible through Git

## Status

| Area | Status |
|---|---|
| Repository structure | In progress |
| Packer template | In progress |
| Terraform provisioning | In progress |
| cloud-init configuration | Planned |
| Ansible baseline | Planned |
| OPNsense firewall VM | Future |
| Monitoring | Future |
| Centralized logging | Future |

## Future Additions

- Firewall and network segmentation with OPNsense on a dedicated VM
- Monitoring with Prometheus and Grafana
- Centralized logging
- Linux hardening
- Backup and restore testing
- Example service deployments such as Nginx or HAProxy
- Automated code checks for Terraform and Ansible using GitHub Actions
