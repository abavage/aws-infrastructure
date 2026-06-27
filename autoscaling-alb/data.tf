data "aws_ami" "centos" {
  most_recent = true
  owners      = ["125523088429"] # CentOS official account

  filter {
    name   = "name"
    values = ["CentOS Stream 9 x86_64 2025*"]
  }
}

data "aws_vpc" "selected" {
  tags = {
    Name = "rosa_public"
  }
}

data "aws_iam_role" "selected" {
  name = "ec2-system-manager-instance-role"
}