packer {
  required_plugins {
    proxmox = {
      version = "1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "almalinux9" {

  insecure_skip_tls_verify = true

  node    = "proxmox"
  vm_name = "almalinux9-template"
  vm_id   = 9001

  cpu_type = "host"
  os       = "l26"
  cores    = "2"
  memory   = "2048"

  disks {
    type         = "sata"
    storage_pool = "local-lvm"
    disk_size    = "20G"
  }

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot_iso {
    type         = "sata"
    iso_file     = "local:iso/AlmaLinux-9.7-x86_64-minimal.iso"
    unmount      = true
    iso_checksum = "sha256:d51ed22cf272a0f30fcf55579d2748ff6ee1fddd6e36ba728cb386b933ceb7fc"
  }

# Lab-only user for initial Packer SSH validation.
# Replace with SSH key-based auth and remove password login in a later hardening pass.

  ssh_host     = "10.10.10.101"
  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout  = "30m"

# Disabled for MVP: qemu_agent is not installed yet.
  qemu_agent = false

  http_directory = "${path.root}/http"
  http_port_min  = 8800
  http_port_max  = 8800

  boot_wait = "3s"


# MVP workaround for nested Hyper-V/Proxmox lab.
# Static IP is used because the internal vSwitch currently has no DHCP.
# This should later be replaced by proper networking.
  boot_command = [
    "<up><tab>",
    " ip=10.10.10.101::10.10.10.1:255.255.255.0:almalinux9-template:ens18:none inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<enter>"
  ]

}

build {
  name    = "almalinux9-x86_64-minimal"
  sources = ["source.proxmox-iso.almalinux9"]

}