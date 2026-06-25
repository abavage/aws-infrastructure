base_name = "httpd"

private_aws_subnet_ids = [
  "subnet-04750674a672f21f8",
  "subnet-049832e4e24cf4383",
  "subnet-0114ea51eaf9371f0"
]


public_aws_subnet_ids = [
  "subnet-07cea7f88f8ccaa79",
  "subnet-05a5e8cb70569eac0",
  "subnet-00a26cdb77934432b"
]

instance_type = "t3.small"
asg_instance_ssh_key = "~/.ssh/one_id_rsa.pub"
region = "ap-southeast-2"
ebs_disk = {
  size = 10
  type = "gp3"
}

instance_count = {
  min = 1
  max = 3
  desired = 2
}

#common_tags = {
#  region = "nonprod"
#  department = "development"
#  propagate_at_launch = true
#}

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