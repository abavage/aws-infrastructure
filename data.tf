data "aws_ami" "centos" {
  most_recent = true
  owners      = ["125523088429"] # CentOS official account

  filter {
    name   = "name"
    values = ["CentOS Stream 9 x86_64 2025*"]
  }
}

data "aws_security_group" "selected" {
  tags = {
    Name = "linux-ec2-common"
  }
}