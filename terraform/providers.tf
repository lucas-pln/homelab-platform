provider "proxmox" {
  insecure = true

  ssh {
    agent    = true
    username = "root"

    node {
      name    = var.node_name
      address = var.proxmox_ssh_address
      port    = 22
    }
  }
}