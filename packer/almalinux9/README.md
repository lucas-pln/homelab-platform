# Packer AlmaLinux 9 Minimal Template

This directory contains a basic Packer configuration for building an AlmaLinux 9 VM on Proxmox using the proxmox-iso builder. 

This is an early MVP configuration. At this stage, the configuration validates the Proxmox API connection and VM creation flow. 

Credentials are not stored in the Packer files. The Proxmox API token is injected at runtime using environment variables.

## Files

```text
packer/
└──almalinux9
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars.example
```