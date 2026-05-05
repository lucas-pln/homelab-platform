packer {
  required_plugins {
    proxmox = {
      version = "1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "almalinux9" {

  proxmox_url              = var.proxmox_url
  insecure_skip_tls_verify = true

  node    = "proxmox"
  vm_name = "almalinux9-template"
  vm_id   = 9001

  boot_iso {
    type     = "scsi"
    iso_file = "local:iso/AlmaLinux-9.7-x86_64-minimal.iso"
    unmount  = true
  }

  ssh_username = "root"

}

build {
  name    = "almalinux9-x86_64-minimal"
  sources = ["source.proxmox-iso.almalinux9"]
}