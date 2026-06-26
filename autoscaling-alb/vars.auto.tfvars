base_name = "httpd"

private_aws_subnet_ids = [
  "subnet-0bfe86cbbcd1fa9ae",
  "subnet-0f299d7ac9a805733",
  "subnet-0b4b836d336ede0f5"
]


public_aws_subnet_ids = [
  "subnet-06be48a11203749d8",
  "subnet-08fa2afb5d3fbdce9",
  "subnet-03d8a0f1e239be33c"
]

instance_type = "t3.nano"
asg_instance_ssh_key = "~/.ssh/one_id_rsa.pub"
region = "ap-southeast-2"
ebs_disk = {
  size = 10
  type = "gp3"
}

instance_count = {
  min = 1
  max = 3
  desired = 1
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
