variable "content_type" {
  type        = string
  description = "Proxmox file content type used for the rendered cloud-init snippet."
  default     = "snippets"
}

variable "file_datastore_id" {
  type        = string
  description = "Proxmox datastore used to store the rendered cloud-init snippet."
  default     = "local"
}

variable "node_name" {
  type        = string
  description = "Proxmox node name used by the provider and as the clone target."
}

variable "machine" {
  type        = string
  description = "QEMU machine type used by the cloned VM."
  default     = "q35"
}

variable "bios" {
  type        = string
  description = "Firmware type used by the cloned VM."
  default     = "ovmf"
}

variable "clone_vm_id" {
  type        = number
  description = "Source Proxmox template VM ID used for cloning."
  default     = 9001
}

variable "clone_full" {
  type        = bool
  description = "Whether the Proxmox clone is created as a full clone."
  default     = true
}

variable "clone_datastore_id" {
  type        = string
  description = "Proxmox datastore used for the cloned VM disk."
  default     = "local-lvm"
}

variable "cores" {
  type        = number
  description = "Number of CPU cores assigned to the cloned VM."
  default     = 2
}

variable "cpu_type" {
  type        = string
  description = "CPU model exposed to the cloned VM."
  default     = "x86-64-v2-AES"
}

variable "dedicated_memory" {
  type        = number
  description = "Dedicated memory assigned to the cloned VM, in MiB."
  default     = 2048
}

variable "disk_interface" {
  type        = string
  description = "Bus type used for the additional data-disk."
  default     = "scsi1"
}

variable "disk_datastore_id" {
  type        = string
  description = "Proxmox storage pool where the additional data-disk is created."
  default     = "local-lvm"
}

variable "disk_size" {
  type        = string
  description = "Size of the additional data-disk created"
  default     = "10"
}

variable "disk_io_thread" {
  type        = bool
  description = "Enables IO threads for compatible disk controllers; set false if using an incompatible SCSI controller."
  default     = true
}

variable "agent_enabled" {
  type        = bool
  description = "Enables the QEMU guest agent for the cloned VM."
  default     = true
}

variable "ipv4" {
  type        = bool
  description = "Waits for an IPv4 address from the QEMU guest agent."
  default     = true
}

variable "network_bridge" {
  type        = string
  description = "Proxmox bridge connected to the cloned VM network device."
  default     = "vmbr0"
}

variable "started" {
  type        = bool
  description = "Whether Terraform starts the cloned VM after provisioning."
  default     = true
}

variable "domain" {
  type        = string
  description = "DNS domain appended to the generated VM hostname in cloud-init."
}

variable "ansible_ssh_public_key" {
  type        = string
  description = "SSH public key added to the ansible user's authorized_keys by cloud-init."
}

variable "proxmox_ssh_address" {
  type        = string
  description = "IP address or hostname used by the Proxmox provider for SSH access to the node."
}
