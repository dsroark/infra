variable "env" {
    default = "sandbox"
}

variable "aws_region" {
    default = "us-east-2"
}
variable "aws_profile" {
    default = "default"
}
data "aws_availability_zones" "available" {}
variable "vpc_cidr" {
    default = "10.1.0.0/16"
}
variable "localip" {}
variable "pubkey" {}

variable "cidrs" {
    type = "map"
    default = {
        "public1": "10.1.0.0/24"
    }
}

variable vpn_instance_name {
    default = "vpn"
}

variable ca_instance_name {
    default = "ca"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
