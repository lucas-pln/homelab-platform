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

Secure Boot support may be added later as a separate image-hardening improvement.

### SCSI disk with VirtIO SCSI single

The system disk is attached as SCSI and uses the `virtio-scsi-single` controller:

```hcl
scsi_controller = "virtio-scsi-single"
```

This also allows `io_thread` support.

### DHCP-based installer network

During installation, the VM receives its temporary network configuration from the lab DHCP server:

DHCP server: network.lab.home.arpa
DNS server:  10.10.10.53
Domain:      lab.home.arpa
DHCP range:  10.10.10.100-199
Gateway:     10.10.10.1

The Kickstart network configuration uses DHCP:

```text
network --bootproto=dhcp --device=link --activate --onboot=on --hostname=almalinux9-template.lab.home.arpa
```

This keeps the template clean and avoids baking a fixed IP address into the image.

The temporary DHCP address is only used during the Packer build. 
Final VM network identity is expected to be provided later through Terraform-managed Proxmox cloud-init settings and applied by cloud-init on first boot.

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

## Provisioning and Cleanup Flow

After the operating system is installed through Kickstart, Packer connects to the VM using the temporary `packer` user created during installation.

Packer then runs provisioners to prepare the VM before it is converted into a template.

The current provisioning flow is:

```text
Kickstart install
→ Packer SSH connection
→ Package update
→ Template cleanup
→ Convert VM to template
```

### Package update

Packer runs `scripts/update.sh` after the Kickstart installation to update installed packages during image creation.

This keeps the base template current at build time instead of relying on cloned VMs to perform large first-boot updates.

### Template cleanup

Packer runs `scripts/cleanup.sh` before converting the VM into a template.

The cleanup script removes build-time state such as package caches, temporary files, installer logs, cloud-init state, SSH host keys, machine identity, random seed state, and temporary Packer access.

This helps ensure cloned VMs receive fresh identity and do not inherit build artifacts from the image build process.

## Files

```text
packer/
└── almalinux9/
    ├── almalinux9.pkr.hcl
    ├── variables.pkr.hcl
    ├── variables.auto.pkrvars.hcl.example
    ├── http/
    │   └── ks.cfg
    ├── scripts/
    │   ├── cleanup.sh
    │   └── update.sh
    └── README.md
```

## Credentials

Proxmox API credentials are not stored in the Packer files.

The Proxmox ISO builder supports reading API credentials from environment variables. In this lab, `direnv` is used to load those variables locally from a non-committed `.env` file based on the example [.env.example](../../.env.example) file.

## Current limitations

This is a working MVP, not a production-grade image pipeline yet.

Current temporary choices:

- SSH uses `packer` lab user with static SSH key authentication.
- The temporary `packer` user is disabled instead of deleted, because it is still active during the final Packer SSH session.
- Proxmox TLS verification is disabled with `insecure_skip_tls_verify = true`.
- Secure Boot is not enabled yet.

## Planned improvements

Short-term:

- Add CI checks for `packer fmt` and `packer validate`.
- Add basic build validation after template creation.
- Improve documentation around the Kickstart, Packer provisioner, and cleanup responsibilities.

Later improvements:

- Add Secure Boot support.
- Generate a temporary SSH keypair per build instead of relying on a static local build key.
- Inject the temporary public key dynamically into Kickstart during the build.
- Run Packer builds from a CI/CD pipeline instead of a manual shell session.
- Scan, test, and promote templates before they are used by Terraform.