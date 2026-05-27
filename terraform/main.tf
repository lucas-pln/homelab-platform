resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = var.content_type
  datastore_id = var.file_datastore_id
  node_name    = var.node_name

  source_raw {
    data      = local.user_data
    file_name = "${local.hostname}-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "almalinux9_clone" {
  name        = local.hostname
  node_name   = var.node_name
  description = "${local.hostname} - Managed by Terraform"
  tags        = ["managed_by_terraform","os_almalinux9","env_lab"]


  machine = var.machine
  bios    = var.bios

  clone {
    vm_id        = var.clone_vm_id
    full         = var.clone_full
    datastore_id = var.clone_datastore_id
  }

  cpu {
    cores = var.cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.dedicated_memory
  }

  disk {
    interface    = var.disk_interface
    datastore_id = var.disk_datastore_id
    size         = var.disk_size
    iothread     = var.disk_io_thread
    serial       = local.disk_serial
  }

  agent {
    enabled = var.agent_enabled

    wait_for_ip {
      ipv4 = var.ipv4
    }
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  started = var.started

}