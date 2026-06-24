resource "aws_key_pair" "ssh_key" {
  key_name   = "httpd_asg_key"
  #public_key = file("~/.ssh/one_id_rsa.pub") ec2_linux_bastion_key
  public_key = file(var.asg_instance_ssh_key)
}

resource "aws_launch_template" "httpd_launch_template" {
  name = "httpd_template"

block_device_mappings {
    device_name = "/dev/sda"

    ebs {
      volume_size = var.ebs_disk.size
      volume_type = var.ebs_disk.type
      delete_on_termination = true
    }
  }

  disable_api_stop        = true
  disable_api_termination = false

  image_id = data.aws_ami.centos.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = var.instance_type

  key_name = aws_key_pair.ssh_key.key_name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  placement {
    availability_zone = var.region
  }

  vpc_security_group_ids = [
    data.aws_security_group.selected.id 
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = filebase64("${path.module}/userdata/common.sh")
}
