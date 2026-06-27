# alb common sg
resource "aws_security_group" "httpd_alb_common_sg" {
  name        = "${var.base_name}-alb-common-sg"
  description = "Controls access to the ALB"
  vpc_id      = data.aws_vpc.selected.id
  tags = {
    Name = "${var.base_name}-alb-common-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "httpd_alb_common_sg" {
  for_each = var.alb_common_sg_rules

  security_group_id = aws_security_group.httpd_alb_common_sg.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
  tags = {
    Name = each.key
  }
}

resource "aws_vpc_security_group_egress_rule" "httpd_alb_common_sg" {
  security_group_id = aws_security_group.httpd_alb_common_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


# referenced_security_group to the ALB SG via a data lookup
resource "aws_security_group" "httpd_instance_sg" {
  name        = "${var.base_name}-instance-common-sg"
  description = "Controls access to the EC2 instances"
  vpc_id      = data.aws_vpc.selected.id
  tags = {
    Name = "${var.base_name}-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "httpd_instance_80_sg" {
  security_group_id            = aws_security_group.httpd_instance_sg.id
  referenced_security_group_id = aws_security_group.httpd_alb_common_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  #cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "httpd_instance_egress" {
  security_group_id = aws_security_group.httpd_instance_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}