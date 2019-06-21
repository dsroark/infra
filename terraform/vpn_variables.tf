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
    default = '{ "public1": "10.1.0.0/24"}/
}
