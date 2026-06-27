resource "aws_key_pair" "ssh_key" {
  key_name = "httpd_asg_key"
  #public_key = file("~/.ssh/one_id_rsa.pub") ec2_linux_bastion_key
  public_key = file(var.asg_instance_ssh_key)
}
resource "random_string" "random" {
  length      = 6
  special     = false
  numeric     = true
  min_numeric = 2
  min_lower   = 4
  min_upper   = 0
}

resource "aws_launch_template" "httpd_launch_template" {
  name = "${var.base_name}_template"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.ebs_disk.size
      volume_type           = var.ebs_disk.type
      delete_on_termination = true
    }
  }

  disable_api_stop        = false
  disable_api_termination = false

  iam_instance_profile {
    name = data.aws_iam_role.selected.name
  }

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

  #network_interfaces {
  #  associate_public_ip_address = false
  #}

  placement {
    availability_zone = var.region
  }

  vpc_security_group_ids = [
    aws_security_group.httpd_instance_sg.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.base_name}-${random_string.random.result}"
    }
  }

  user_data = filebase64("${path.module}/userdata/common.sh")
}

resource "aws_autoscaling_group" "httpd_autoscaling_group" {
  name                      = "${var.base_name}_autoscaling_group"
  min_size                  = var.instance_count.min
  max_size                  = var.instance_count.max
  desired_capacity          = var.instance_count.desired
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  #placement_group           = aws_placement_group.test.id
  launch_template {
    id      = aws_launch_template.httpd_launch_template.id
    version = aws_launch_template.httpd_launch_template.latest_version
  }
  target_group_arns = [
    aws_lb_target_group.httpd_target_group.arn
  ]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      skip_matching          = true
    }
    triggers = [
      "tag"
    ]
  }

  vpc_zone_identifier = var.private_aws_subnet_ids
  termination_policies = [
    "OldestInstance"
  ]

  #instance_maintenance_policy {
  #  min_healthy_percentage = 90
  #  max_healthy_percentage = 120
  #}

  #initial_lifecycle_hook {
  #  name                 = "foobar"
  #  default_result       = "CONTINUE"
  #  heartbeat_timeout    = 2000
  #  lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

  #  notification_metadata = jsonencode({
  #    foo = "bar"
  #  })

  #  notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
  #  role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  #}

  dynamic "tag" {
    for_each = var.common_tags

    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  timeouts {
    delete = "15m"
  }
  depends_on = [
    aws_launch_template.httpd_launch_template
  ]
}