variable "domain" {
  type        = string
  description = "Network domain used for FQDN"
}

variable "ansible_ssh_public_key" {
  type        = string
  description = "Public SSH key injected into the Ansible user via cloud-init."
}

variable "node_name" {
  type        = string
  description = "Hostname of the Proxmox node"
}

variable "proxmox_ssh_address" {
  type        = string
  description = "IP of the Proxmox node"
}