terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.106.0"
    }
  }
}

provider "proxmox" {

  insecure = true
}

resource "proxmox_virtual_environment_vm" "almalinux9_clone" {
  name      = "almalinux9-clone"
  node_name = "proxmox"
  vm_id     = 101

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
  }

  initialization {

    datastore_id = "local-lvm"
    upgrade      = false

    user_account {
      username = "ansible"
      keys     = [trimspace(file("~/.ssh/ansible/ansible-user.pub"))]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  started = true

}

output "ip_address" {
  value = proxmox_virtual_environment_vm.almalinux9_clone.ipv4_addresses[1][0]
}