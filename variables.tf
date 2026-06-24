variable "region" {
  type = string
  nullable = false
  description = "Default region"
}

variable "private_aws_subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "list of the private subnets"
}

variable "public_aws_subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "list of the public subnets"
}

variable "instance_type" {
  type = string
  nullable = false
  description = "Instace type to use in the launch template"
 
}

variable "asg_instance_ssh_key" {
  type = string 
  default = null
  description = "ssh key name to access the ec2 instance full path to the local file ~/.ssh/somefile.pub"
}

variable "ebs_disk" {
  type = map(string)
  description = "Type and size for the ebs disk"
  default = {
    size = ""
    type = ""
  }
}