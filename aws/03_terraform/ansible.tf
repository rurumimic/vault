data "template_file" "ansible" {
  template   = file("./ansible/template.sh")
  depends_on = [module.ec2]
  vars = {

    # Vault
    private_ip  = join(" ", module.ec2.private_ip)
    private_key = var.private_key
    user        = var.user

    # Bastion
    bastion_ip          = data.aws_eip.bastion.public_ip
    bastion_user        = var.bastion_user
    bastion_private_key = var.bastion_private_key

    # KMS
    region     = var.region
    kms_key_id = var.kms_key_id

    # Sleep timeout waiting for cloud provider instances
    sleep-timeout = var.sleep_timeout
  }
}

resource "null_resource" "run-ansible" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = join(",", module.ec2.id)
  }

  # Run Ansible
  provisioner "local-exec" {
    command = data.template_file.ansible.rendered
  }
}
