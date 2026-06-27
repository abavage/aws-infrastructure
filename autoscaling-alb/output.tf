output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer — use this to reach the service."
  value       = aws_lb.httpd_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.httpd_alb.arn
}

output "target_group_arn" {
  description = "ARN of the target group registered by the ASG."
  value       = aws_lb_target_group.httpd_target_group.arn
}

output "asg_name" {
  description = "Name of the Auto Scaling group."
  value       = aws_autoscaling_group.httpd_autoscaling_group.name
}

output "launch_template_id" {
  description = "ID of the launch template used by the ASG."
  value       = aws_launch_template.httpd_launch_template.id
}

output "instance_security_group_id" {
  description = "Security group attached to EC2 instances (allows HTTP from the ALB SG)."
  value       = aws_security_group.httpd_instance_sg.id
}

output "alb_security_group_id" {
  description = "Referenced ALB security group (alb-common) — source for instance ingress on port 80."
  value       = aws_security_group.httpd_alb_common_sg.id
}
