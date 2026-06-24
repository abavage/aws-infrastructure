private_aws_subnet_ids = [
  "subnet-02151632ef4b80f4f",
  "subnet-08ec5faf8f9f54c5b",
  "subnet-08cd6fcd1afaa4c58",
]


public_aws_subnet_ids = [
  "subnet-0763aec1d7efceb8d"
]

instance_type = "t3.small"
asg_instance_ssh_key = "~/.ssh/one_id_rsa.pub"
region = "ap-southeast-2"
ebs_disk = {
  size = 10
  type = "gp3"
}