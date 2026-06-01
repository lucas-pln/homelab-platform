# Packer AlmaLinux 9 Minimal Template

This directory contains a Packer configuration to build an AlmaLinux 9 VM template on Proxmox using the `proxmox-iso` builder.

The current state implements a working image-build workflow:

```text
Packer → Proxmox VM → AlmaLinux ISO → Kickstart install → SSH validation → Proxmox template
```

## Design choices

### AlmaLinux DVD ISO

The build uses the AlmaLinux DVD ISO rather than the minimal ISO. The DVD ISO is larger, but it provides package availability for the minimal OS install and the later Packer package installation step.

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

```text
DHCP server: network.lab.home.arpa
DNS server:  10.10.10.53
Domain:      lab.home.arpa
DHCP range:  10.10.10.100-199
Gateway:     10.10.10.1
```

The Kickstart network configuration uses DHCP:

```text
network --bootproto=dhcp --device=link --activate --onboot=on
```

This keeps the template clean and avoids baking a fixed IP address into the image.

The temporary DHCP address is only used during the Packer build.
Terraform provides the final hostname and FQDN through cloud-init when a VM is cloned.

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

### Baseline package set

Kickstart installs only the AlmaLinux minimal environment:

```text
@^minimal-environment
```

Packer then installs the template integration packages currently required by the clone workflow:

```text
qemu-guest-agent
cloud-init
```

## Provisioning and Cleanup Flow

After the operating system is installed through Kickstart, Packer connects to the VM as `root` using the SSH key injected by Kickstart.

Packer then runs provisioners to prepare the VM before it is converted into a template.

The current provisioning flow is:

```text
Kickstart install
→ Packer SSH connection
→ Install template packages
→ Write template metadata
→ Download metadata artifact
→ Finalize template
→ Convert VM to template
```

### Template packages

Packer runs `scripts/00-install-template-packages.sh` after the Kickstart installation.

The script installs and enables `qemu-guest-agent` and `cloud-init`, then checks that both are available.

### Template metadata

Packer runs `scripts/10-write-template-metadata.sh` to write `/etc/template-build.json` inside the image.

The metadata includes the template OS, major version, role label, build tool, ISO checksum, and UTC build date. Packer then downloads that file to a local artifact path under `artifacts/`.

### Template finalization

Packer runs `scripts/20-finalize-template.sh` before converting the VM into a template.

The finalization script removes package caches, temporary files, installer logs, cloud-init state, SSH host keys, machine identity, random seed state, root SSH access, system logs, and shell/download history.

This helps ensure cloned VMs receive fresh identity and do not inherit build artifacts from the image build process.

First-boot identity, cloud-init completion, hostname/FQDN, and IPv4 DNS resolution are validated after Terraform cloning by the Ansible clone validation playbook.

## Files

```text
packer/
└── almalinux9/
    ├── almalinux9.pkr.hcl
    ├── variables.pkr.hcl
    ├── variables.auto.pkrvars.hcl.example
    ├── homelab-platform-ci-test.pkrvars.hcl
    ├── http/
    │   └── ks.cfg
    ├── scripts/
    │   ├── 00-install-template-packages.sh
    │   ├── 10-write-template-metadata.sh
    │   └── 20-finalize-template.sh
    └── README.md
```

## Credentials

Proxmox API credentials are not stored in the Packer files.

The Proxmox ISO builder supports reading API credentials from environment variables. In this lab, `direnv` is used to load those variables locally from a non-committed `.env` file based on the example [.env.example](../../.env.example) file.

## Current limitations

This is a lab implementation, not a production image pipeline.

Current temporary choices:

- SSH uses root key authentication during the build.
- The build key is static local input rather than generated per build.
- Secure Boot is not enabled yet.

## Planned improvements

Short-term:

- Add deeper image promotion checks before templates are consumed by Terraform.
- Improve documentation around the Kickstart, Packer provisioner, and cleanup responsibilities.

Later improvements:

- Add Secure Boot support.
- Generate a temporary SSH keypair per build instead of relying on a static local build key.
- Inject the temporary public key dynamically into Kickstart during the build.
- Run Packer builds from a CI/CD pipeline instead of a manual shell session.
- Scan, test, and promote templates before they are used by Terraform.
