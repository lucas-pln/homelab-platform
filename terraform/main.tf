terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.105.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.endpoint
  insecure = true
}

data "proxmox_virtual_environment_nodes" "available" {}

output "proxmox_nodes" {
  value = data.proxmox_virtual_environment_nodes.available.names
}