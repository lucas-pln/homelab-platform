build {
  name    = var.build_name
  sources = ["source.proxmox-iso.almalinux9"]

  provisioner "shell" {
    script          = "scripts/00-install-template-packages.sh"
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Path }}"
  }

  provisioner "shell" {
    script          = "scripts/10-write-template-metadata.sh"
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }}"

    environment_vars = [
      "TEMPLATE_OS=${var.template_os}",
      "TEMPLATE_MAJOR_VERSION=${var.template_major_version}",
      "TEMPLATE_ROLE=${var.template_role}",
      "ISO_CHECKSUM=${var.iso_checksum}"
    ]
  }

  provisioner "shell" {
    script            = "scripts/20-finalize-template.sh"
    remote_path       = "/home/packer/packer-finalize-template.sh"
    execute_command   = "chmod +x {{ .Path }}; sudo {{ .Path }}"
    skip_clean        = true
    expect_disconnect = true
  }

  post-processor "manifest" {
    output     = "${local.output_dir}/manifest-${local.artifact_name}.json"
    strip_path = true

    custom_data = {
      template_os            = var.template_os
      template_major_version = var.template_major_version
      template_role          = var.template_role
      iso_checksum           = var.iso_checksum
      build_date             = timestamp()
    }
  }
}
