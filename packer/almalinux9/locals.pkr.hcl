locals {
  http_directory = "${path.root}/http"

  boot_command = [
    "<up>e<down><down><end>",
    " inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]

  output_dir    = "artifacts"
  artifact_name = "${var.template_os}${var.template_major_version}-${var.template_role}"
}
