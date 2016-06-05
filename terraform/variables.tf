variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION

  default = "~/.ssh/ghost.pub"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "ghost"
}

variable "instance_type" {
  default     = "t2.small"
  description = "AWS instance type"
}

variable "region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "azs" {
  default = {
    us-west-2 = "us-west-2a,us-west-2b,us-west-2c"
  }
}

# Ubuntu Trusty 14.04 LTS (x64) with Node.js installed
variable "amis" {
  default = {
    us-west-2 = "ami-9abea4fb"
  }
}

variable "vpc_cidr_prefix" {
  default = {
    us-west-2 = "10.8"
  }
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "3"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "5"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "3"
}

variable "hosted_zone_id" {
  description = "The zone id of the application"
  default     = "Z3OKXUGAIRMFVA"
}

variable "ghost_domain" {
  description = "The domain of the ghost"
  default     = "ghost.awsrun.com"
}
