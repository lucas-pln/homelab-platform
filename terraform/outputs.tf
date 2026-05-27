output "vm_fqdn" {
  description = "FQDN assigned to the VM through cloud-init/DNS."
  value = local.fqdn
}

output "vm_ipv4_address" {
    description = "IPv4 addresses reported by the QEMU guest agent."
  value = proxmox_virtual_environment_vm.almalinux9_clone.ipv4_addresses[1][0]
}

output "vm_tags" {
  description = "Proxmox tags assigned to the VM."
  value = proxmox_virtual_environment_vm.almalinux9_clone.tags
}