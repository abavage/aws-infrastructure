resource "aws_lb" "httpd_alb" {
  name               = "${var.base_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    #data.aws_security_group.selected.id
    aws_security_group.httpd_alb_common_sg.id
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