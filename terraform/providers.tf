provider "proxmox" {

  ssh {
    agent    = true
    username = "terraform-upload"

    node {
      name    = var.node_name
      address = var.proxmox_ssh_address
      port    = 22
    }
  }
}