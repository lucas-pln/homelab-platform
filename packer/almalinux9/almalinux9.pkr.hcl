packer {
  required_plugins {
    proxmox = {
      version = "1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

locals {
  http_directory = "${path.root}/http"

  boot_command = [
    "<up>e<down><down><end>",
    " inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]

  build_date = formatdate("YYYYMMDD", timestamp())

  metadata_file = "artifacts/${local.build_date}-${var.template_os}${var.template_major_version}-build-${var.template_role}.json"
}

source "proxmox-iso" "almalinux9" {
  node            = var.node
  vm_name         = var.vm_name
  vm_id           = var.vm_id
  bios            = var.bios
  machine         = var.machine
  cpu_type        = var.cpu_type
  os              = var.os
  cores           = var.cores
  memory          = var.memory
  scsi_controller = var.scsi_controller

  network_adapters {
    model  = var.network_model
    bridge = var.network_bridge
  }

  boot_iso {
    type         = var.boot_iso_type
    iso_file     = var.iso_file
    unmount      = true
    iso_checksum = var.checksum
  }

  disks {
    type         = var.disks_type
    storage_pool = var.disks_storage_pool
    disk_size    = var.disks_disk_size
    io_thread    = var.disks_io_thread
  }

  efi_config {
    efi_storage_pool  = var.efi_storage_pool
    efi_format        = var.efi_format
    efi_type          = var.efi_type
    pre_enrolled_keys = false # Not including Secure Boot yet in this MVP
  }

  cloud_init              = var.cloud_init
  cloud_init_storage_pool = var.cloud_init_storage_pool
  cloud_init_disk_type    = var.cloud_init_disk_type

  boot_wait    = var.boot_wait
  boot_command = local.boot_command

  communicator         = var.communicator
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.private_key_file
  ssh_timeout          = var.ssh_timeout

  http_directory = local.http_directory
  http_port_min  = var.http_port_min
  http_port_max  = var.http_port_max
  qemu_agent     = true

}
build {
  name    = var.build_name
  sources = ["source.proxmox-iso.almalinux9"]

  provisioner "shell" {
    scripts = ["scripts/00-install-template-packages.sh"]
  }

  provisioner "shell" {
    scripts = ["scripts/10-write-template-metadata.sh"]

    environment_vars = [
      "TEMPLATE_OS=${var.template_os}",
      "TEMPLATE_MAJOR_VERSION=${var.template_major_version}",
      "TEMPLATE_ROLE=${var.template_role}",
      "ISO_CHECKSUM=${var.checksum}"
    ]
  }

  provisioner "file" {
    direction   = "download"
    source      = "/etc/template-build.json"
    destination = local.metadata_file
  }

  provisioner "shell" {
    scripts = ["scripts/20-finalize-template.sh"]
  }
}
