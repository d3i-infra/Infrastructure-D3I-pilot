# Configure templates for cloud-init
# These templates are consumed by the vm

data "template_file" "cloud-init-user-data" {
  template = file("./cloudinit/userdata.yaml")
  vars = {
    admin_username = var.admin_username
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloud-init-user-data.rendered}"
  }
}

output "userdata" {
  value = "\n${data.template_file.cloud-init-user-data.rendered}"
}

