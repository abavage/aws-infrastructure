variable "base_name" {
  type        = string
  nullable    = false
  description = "Common name for all related objectes"
}

variable "region" {
  type        = string
  nullable    = false
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
  type        = string
  nullable    = false
  description = "Instace type to use in the launch template"

}

variable "asg_instance_ssh_key" {
  type        = string
  default     = null
  description = "ssh key name to access the ec2 instance full path to the local file ~/.ssh/somefile.pub"
}

variable "ebs_disk" {
  type        = map(string)
  description = "Type and size for the ebs disk"
  default = {
    size = ""
    type = ""
  }
}

variable "instance_count" {
  type        = map(number)
  description = "Min, max, desired count for the ASG"
  default = {
    min     = null
    max     = null
    desired = null
  }
}

variable "alb_common_sg_rules" {
  type        = map(any)
  description = "Common ALB SG"
  default     = null
}

#variable "common_tags" {
#  type = map(string)
#  description =  "Common tags to be added"
#  default = null
#}

variable "common_tags" {
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  description = "Common tags to be added"
  default     = [] # Changed default to an empty list
}