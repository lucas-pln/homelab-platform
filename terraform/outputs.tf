output "vm_hostname" {
  value = local.hostname
}

output "vm_fqdn" {
  value = local.fqdn
}

output "vm_ipv4_addresses" {
  value = proxmox_virtual_environment_vm.almalinux9_test_clone.ipv4_addresses
}