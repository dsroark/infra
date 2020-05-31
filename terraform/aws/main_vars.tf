variable "aws_region" {
    default = "us-east-2"
}
variable "aws_profile" {
    default = "default"
}

variable "cidr_map_bits" {
  default = 2
}

variable "cidr_subnit_bits" {
  default = 3
}

variable "ipv6_cidr_map_bits" {
  default = 3
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}
variable "pubkey" {}
variable "localip" {}

