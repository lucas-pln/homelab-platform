# Packer AlmaLinux 9 Minimal Template

This directory contains a Packer configuration to build an AlmaLinux 9 VM template on Proxmox using the `proxmox-iso` builder. 

The current state validates a complete image-build workflow:

```text
Packer → Proxmox VM → AlmaLinux ISO → Kickstart install → SSH validation → Proxmox template
```

## Design choices

### AlmaLinux DVD ISO

The build uses the AlmaLinux DVD ISO rather than the minimal ISO. The DVD ISO is larger, but it provides a better offline package source during Kickstart installation.
This avoids build failures caused by missing packages such as `qemu-guest-agent`, `cloud-init`, or other tools.

### UEFI / OVMF

The template uses UEFI through Proxmox OVMF firmware:

```hcl
bios    = "ovmf"
machine = "q35"
```

Secure Boot is disabled for the moment:

```hcl
pre_enrolled_keys = false
```

It will most probably be added later during a separate hardening stage.

### SCSI disk with VirtIO SCSI single

The system disk is attached as SCSI and uses the `virtio-scsi-single` controller:

```hcl
scsi_controller = "virtio-scsi-single"
```

This also allows `io_thread` support.

### Static installer network

DHCP is not yet part of the lab network, so the installer uses a static IP during installation.

Current values:

```text
VM template IP:  10.10.10.101
Gateway:         10.10.10.1
Interface:       enp6s18
Kickstart HTTP:  port 8800
```

This will later be replaced with a cleaner DHCP reservation.

### Kickstart over temporary HTTP

Packer serves the Kickstart file from local `http/` directory during the build:

```text
http/ks.cfg
```

The installer receives the Kickstart URL through GRUB kernel arguments:

```text
inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg
```

For this lab, the HTTP port is fixed to `8800`, so the control node firewall must allow inbound TCP/8800 traffic from the VM template network.

```bash
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.10.10.0/24" port port="8800" protocol="tcp" accept'
sudo firewall-cmd --reload
```

### Baseline packages

The build process installs a small baseline of packages for system administration, Proxmox integration, cloning, and Ansible management:

```text
qemu-guest-agent
cloud-init
cloud-utils-growpart
openssh-server
sudo
python3
python3-libselinux
curl / wget / rsync / tar / gzip
vim-enhanced
bash-completion
chrony
firewalld
NetworkManager
dnf-plugins-core
```

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

## Credentials

Proxmox API credentials are not stored in the Packer files.

The Proxmox ISO builder supports reading API credentials from environment variables. In this lab, `direnv` is used to load those variables locally from a non-committed `.env` file based on the example [.env.example](../../.env.example) file.

## Current limitations

This is a working MVP, not a production-grade image pipeline yet.

Current temporary choices:

- Static IP in the Packer boot command.
- Kickstart configures static IP.
- SSH uses `packer/packer` lab user with password authentication.
- Proxmox TLS verification is disabled with `insecure_skip_tls_verify = true`.
- Secure Boot is not enabled yet.
- No cleanup steps before templating..

## Planned improvements

Short-term:

- Replace password authentication with SSH key authentication.
- Remove `packer` user and add cleanup steps before templating.

Later improvements:

- Replace the static IP with DHCP.
- Add CI checks for `packer fmt` and `packer validate`.
- Secure Boot support.