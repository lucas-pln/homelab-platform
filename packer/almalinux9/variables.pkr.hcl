variable "node" {
  type = string
}

variable "vm_name" {
  type    = string
  default = "almalinux9-builder"
}

variable "vm_id" {
  type    = number
  default = 9001
}

variable "bios" {
  type    = string
  default = "ovmf"
}

variable "machine" {
  type    = string
  default = "q35"
}

variable "cpu_type" {
  type    = string
  default = "host"
}

variable "os" {
  type    = string
  default = "l26"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "scsi_controller" {
  type    = string
  default = "virtio-scsi-single"
}

variable "network_model" {
  type    = string
  default = "virtio"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

# Can be changed to 'ide' for old legacy ISOs
variable "boot_iso_type" {
  type    = string
  default = "sata"
}

variable "iso_file" {
  type = string
}

variable "checksum" {
  type = string
}

# Can be changed to 'sata' if compatibility issue
variable "disks_type" {
  type    = string
  default = "scsi"
}

variable "disks_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "disks_disk_size" {
  type    = string
  default = "20G"
}

# /!\ Set to false if scsi_controller is changed from default
variable "disks_io_thread" {
  type    = bool
  default = true
}

variable "efi_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "efi_format" {
  type    = string
  default = "raw"
}

variable "efi_type" {
  type    = string
  default = "4m"
}

variable "cloud_init" {
  type    = bool
  default = true
}

variable "cloud_init_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "cloud_init_disk_type" {
  type    = string
  default = "ide"
}

variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "communicator" {
  type    = string
  default = "ssh"
}

variable "ssh_username" {
  type    = string
  default = "packer"
}

variable "private_key_file" {
  type      = string
  sensitive = true
}

variable "ssh_timeout" {
  type    = string
  default = "30m"
}

# Need to edit firewall rules if port changed from default value
variable "http_port_min" {
  type    = number
  default = 8800
}

# Need to edit firewall rules if port changed from default value
variable "http_port_max" {
  type    = number
  default = 8800
}

variable "build_name" {
  type    = string
  default = "tpl-almalinux9-base"
}