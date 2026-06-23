variable "node" {
  type        = string
  description = "Proxmox node where the temporary build VM is created."
}

variable "vm_name" {
  type        = string
  description = "Name assigned to the temporary VM used during the Packer build."
  default     = "almalinux9-builder"
}

variable "vm_id" {
  type        = number
  description = "Proxmox VM ID assigned to the temporary build VM."
  default     = 9001
}

variable "bios" {
  type        = string
  description = "Firmware type used by the VM; ovmf enables UEFI boot."
  default     = "ovmf"
}

variable "machine" {
  type        = string
  description = "QEMU machine type used for the VM hardware model."
  default     = "q35"
}

variable "cpu_type" {
  type        = string
  description = "CPU model exposed to the guest VM."
  default     = "x86-64-v2-AES"
}

variable "os" {
  type        = string
  description = "Proxmox guest OS type; l26 represents a Linux 2.6 or newer kernel."
  default     = "l26"
}

variable "cores" {
  type        = number
  description = "Number of CPU cores allocated to the temporary build VM."
  default     = 2
}

variable "memory" {
  type        = number
  description = "Memory allocated to the temporary build VM, in MiB."
  default     = 2048
}

variable "scsi_controller" {
  type        = string
  description = "SCSI controller used for VM disks."
  default     = "virtio-scsi-single"
}

variable "network_model" {
  type        = string
  description = "Virtual network adapter model exposed to the guest."
  default     = "virtio"
}

variable "network_bridge" {
  type        = string
  description = "Proxmox bridge connected to the VM network adapter."
  default     = "vmbr0"
}

variable "iso_type" {
  type        = string
  description = "Bus type used to attach the installer ISO; use ide for older legacy ISOs if needed."
  default     = "sata"
}

variable "iso_file" {
  type        = string
  description = "Path or storage reference to the AlmaLinux installer ISO in Proxmox."
}

variable "iso_checksum" {
  type        = string
  description = "Checksum used by Packer to verify the installer ISO."
}

variable "disks_type" {
  type        = string
  description = "Bus type used for the template OS disk; sata can be used for compatibility if needed."
  default     = "scsi"
}

variable "disks_storage_pool" {
  type        = string
  description = "Proxmox storage pool where the template OS disk is created."
  default     = "local-lvm"
}

variable "disks_disk_size" {
  type        = string
  description = "Size of the template OS disk; role-specific data disks are attached later by Terraform."
  default     = "20G"
}

variable "disks_io_thread" {
  type        = bool
  description = "Enables IO threads for compatible disk controllers; set false if using an incompatible SCSI controller."
  default     = true
}

variable "efi_storage_pool" {
  type        = string
  description = "Proxmox storage pool where the EFI disk is created."
  default     = "local-lvm"
}

variable "efi_format" {
  type        = string
  description = "Disk format used for the EFI disk."
  default     = "raw"
}

variable "efi_type" {
  type        = string
  description = "EFI disk size/type used by Proxmox for OVMF firmware variables."
  default     = "4m"
}

variable "cloud_init" {
  type        = bool
  description = "Adds a Proxmox cloud-init drive to the template VM."
  default     = true
}

variable "cloud_init_storage_pool" {
  type        = string
  description = "Proxmox storage pool where the cloud-init drive is created."
  default     = "local-lvm"
}

variable "cloud_init_disk_type" {
  type        = string
  description = "Bus type used to attach the Proxmox cloud-init drive."
  default     = "ide"
}

variable "boot_wait" {
  type        = string
  description = "Delay before Packer sends the automated boot command to the installer."
  default     = "5s"
}

variable "communicator" {
  type        = string
  description = "Packer communicator used to connect to the guest during provisioning."
  default     = "ssh"
}

variable "ssh_username" {
  type        = string
  description = "SSH user used by Packer provisioners."
  default     = "packer"
}

variable "private_key_file" {
  type        = string
  description = "Path to the private SSH key used by Packer to authenticate to the build VM."
  sensitive   = true
}

variable "ssh_timeout" {
  type        = string
  description = "Maximum time Packer waits for SSH to become available after installation."
  default     = "30m"
}

variable "http_port_min" {
  type        = number
  description = "Start of the local HTTP port range used to serve Kickstart files to Anaconda; update firewall rules if changed."
  default     = 8800
}

variable "http_port_max" {
  type        = number
  description = "End of the local HTTP port range used to serve Kickstart files to Anaconda; update firewall rules if changed."
  default     = 8800
}

variable "build_name" {
  type        = string
  description = "Name assigned to the Packer build and resulting AlmaLinux base template."
  default     = "tpl-almalinux9-base"
}

variable "template_os" {
  type        = string
  description = "Operating system name written into build manifest during provisioning."
  default     = "almalinux"
}

variable "template_major_version" {
  type        = number
  description = "Major operating system version written into build manifest during provisioning."
  default     = 9
}

variable "template_role" {
  type        = string
  description = "Role label written into build manifest during provisioning."
  default     = "role-neutral"
}

variable "tags" {
  type        = string
  description = "Tags assigned to the Packer build"
  default     = "template;managed_by_packer;os_almalinux9"
}
