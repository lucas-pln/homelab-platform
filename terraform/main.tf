resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = var.content_type
  datastore_id = var.datastore_id
  node_name    = var.node_name

  source_raw {
    data      = local.user_data
    file_name = "${local.hostname}-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "almalinux9_test_clone" {
  name      = local.hostname
  node_name = var.node_name

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

  agent {
    enabled = var.agent_enabled
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  started = var.started

}