# Packer AlmaLinux 9 Minimal Template

This directory contains a basic Packer configuration for building an AlmaLinux 9 VM template on Proxmox using the `proxmox-iso` builder. 

This is an early MVP configuration for a nested Hyper-V/Proxmox lab. At this stage, the goal is to validate the full image build chain:

```text
Packer → Proxmox VM → AlmaLinux ISO → Kickstart install → SSH validation
```
Proxmox API credentials are not stored in the Packer files. The Proxmox API token is injected at runtime using environment variables.

## Files

```text
packer/
└── almalinux9/
    ├── almalinux9.pkr.hcl
    ├── variables.pkr.hcl
    ├── variables.auto.pkrvars.hcl.example
    ├── http/
    │   └── ks.cfg
    └── README.md
```

## Current limitations

This is a working MVP, not a production-grade image build yet.

Current temporary choices:
- Static build IP is hardcoded in the Packer boot command.
- Kickstart configures a static IP manually.
- SSH uses a temporary `packer/packer` lab user.
- `qemu-guest-agent` is not enabled yet.
- SATA is used instead of SCSI for ISO and disk because of AlmaLinux Anaconda detection issues in the nested lab.