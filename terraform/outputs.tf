output "vm_hostname" {
  value = local.hostname
}

output "vm_fqdn" {
  value = local.fqdn
}

output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.almalinux9_test_clone.ipv4_addresses[1][0]
}