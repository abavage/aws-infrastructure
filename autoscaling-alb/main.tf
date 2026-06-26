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


# referenced_security_group to the ALB SG via a data lookup
resource "aws_security_group" "httpd_instance_sg" {
  name        = "${var.base_name}-instance-sg"
  description = "Controls access to the EC2 instances"
  vpc_id      = data.aws_vpc.selected.id
  tags = {
    Name = "${var.base_name}-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "httpd_instance_80_sg" {
  security_group_id            = aws_security_group.httpd_instance_sg.id
  referenced_security_group_id = data.aws_security_group.selected.id
  from_port                    = 80
  to_port                      = 80
  #cidr_ipv4         = "0.0.0.0/0"
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "httpd_instance_egress" {
  security_group_id = aws_security_group.httpd_instance_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
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


resource "aws_lb" "httpd_alb" {
  name               = "${var.base_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    data.aws_security_group.selected.id
  ]
  subnets = var.public_aws_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}


resource "aws_lb_target_group" "httpd_target_group" {
  name                          = "${var.base_name}-target-group"
  target_type                   = "instance"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = data.aws_vpc.selected.id
  load_balancing_algorithm_type = "round_robin"
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 10
    matcher             = "200"
    path                = "/index.html"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 6
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "httpd_listener" {
  load_balancer_arn = aws_lb.httpd_alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.httpd_target_group.arn
  }
  depends_on = [
    aws_lb_target_group.httpd_target_group
  ]
}

# Scale out
resource "aws_autoscaling_policy" "httpd_autoscaling_policy_out" {
  name                   = "${var.base_name}-autoscaling-policy-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.httpd_autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "httpd_ec2_cloudwatch_metric_alarm_out" {
  alarm_name          = "${var.base_name}-ec2-cloudwatch-metric-alarm-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 50

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.httpd_autoscaling_group.name
  }

  alarm_description = "Scale out metric monitors ec2 cpu utilization"
  alarm_actions = [
    aws_autoscaling_policy.httpd_autoscaling_policy_out.arn
  ]
}

# Scale in
resource "aws_autoscaling_policy" "httpd_autoscaling_policy_in" {
  name                   = "${var.base_name}-autoscaling-policy-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.httpd_autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "httpd_ec2_cloudwatch_metric_alarm_in" {
  alarm_name          = "${var.base_name}-ec2-cloudwatch-metric-alarm-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.httpd_autoscaling_group.name
  }

  alarm_description = "Scale in metric monitors ec2 cpu utilization"
  alarm_actions = [
    aws_autoscaling_policy.httpd_autoscaling_policy_in.arn
  ]
}


