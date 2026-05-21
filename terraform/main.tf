resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox"

  source_raw {
    data      = local.user_data
    file_name = "${local.hostname}-user-data.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "almalinux9_test_clone" {
  name      = local.hostname
  node_name = var.node_name
  vm_id     = 101
  machine   = "q35"
  bios      = "ovmf"


  clone {
    vm_id        = 9001
    full         = true
    datastore_id = "local-lvm"
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  agent {
    enabled = true

    wait_for_ip {
      ipv4 = true
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  started = true

}