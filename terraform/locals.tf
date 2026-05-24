resource "random_pet" "vm_name" {
  prefix    = "virtual"
  length    = 2
  separator = "-"
}

resource "random_id" "disk_serial" {
  byte_length = 10
}

locals {
  hostname = random_pet.vm_name.id
  fqdn     = "${local.hostname}.${var.domain}"

  user_data = templatefile("${path.module}/cloud-init/user-data.yaml.tftpl", {
    hostname               = local.hostname
    fqdn                   = local.fqdn
    ansible_ssh_public_key = var.ansible_ssh_public_key
  })

  disk_serial = random_id.disk_serial.hex
}