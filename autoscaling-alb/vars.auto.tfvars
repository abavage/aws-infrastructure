base_name = "httpd"

private_aws_subnet_ids = [
  "subnet-0dd20c2221265fffc",
  "subnet-0fe687cbd5bbdfa59",
  "subnet-00f44e40f34be8ea9"
]


public_aws_subnet_ids = [
  "subnet-004cde1b63113e642",
  "subnet-04fb531b8ba20e22c",
  "subnet-048c2d007336f1d0d"
]

instance_type        = "t3.nano"
asg_instance_ssh_key = "~/.ssh/one_id_rsa.pub"
region               = "ap-southeast-2"
ebs_disk = {
  size = 10
  type = "gp3"
}

instance_count = {
  min     = 1
  max     = 2
  desired = 1
}

#common_tags = {
#  region = "nonprod"
#  department = "development"
#  propagate_at_launch = true
#}

alb_common_sg_rules = {
  "http" = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "tcp"
  }
  "https" = {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "tcp"
  }
}

common_tags = [
  {
    key                 = "Region"
    value               = "nonprod"
    propagate_at_launch = true
  },
  {
    key                 = "Owner"
    value               = "DevOps"
    propagate_at_launch = true
  }
]
