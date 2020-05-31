provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "available" {
  state = "available"
}
output "zones" {
  value = data.aws_availability_zones.available
}

# VPC

resource "aws_vpc" "vpc" {
    cidr_block  = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    assign_generated_ipv6_cidr_block = true

    tags = {
      Name = "${terraform.workspace}_vpc"
      env  = "${terraform.workspace}"
    }
}

# internet gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${terraform.workspace}-igw"
    env  = "${terraform.workspace}"
  }
}


resource "aws_egress_only_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${terraform.workspace}-egw"
  }
}

# route tables

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${terraform.workspace}_public_route_table"
    env  = "${terraform.workspace}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    ipv6_cidr_block = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.gateway.id
  }
  tags = {
    Name = "${terraform.workspace}_private_route_table"
    env  = "${terraform.workspace}"
  }
}

#subnets

locals {
  cidr_map      = cidrsubnets(
                    var.vpc_cidr,
                    var.cidr_map_bits,
                    var.cidr_map_bits,
                    var.cidr_map_bits
                  )
  ipv6_cidr_map = cidrsubnets(
                    aws_vpc.vpc.ipv6_cidr_block,
                    var.ipv6_cidr_map_bits,
                    var.ipv6_cidr_map_bits,
                    var.ipv6_cidr_map_bits
                  )
}

resource "aws_subnet" "public_subnets" {
  for_each = toset(data.aws_availability_zones.available.zone_ids)

  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true
  availability_zone_id = each.value
  cidr_block = cidrsubnet(
    local.cidr_map[0], var.cidr_subnit_bits, index(
      data.aws_availability_zones.available.zone_ids, each.key
    )
  )
  ipv6_cidr_block = cidrsubnet(
    local.ipv6_cidr_map[0], 8 - var.ipv6_cidr_map_bits, index(
      data.aws_availability_zones.available.zone_ids, each.key
    )
  )
 

  tags = {
    Name = "${terraform.workspace}_public_${each.key}"
    env = "${terraform.workspace}"
    Tier = "Public"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnets" {
  for_each = toset(data.aws_availability_zones.available.zone_ids)

  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = false
  assign_ipv6_address_on_creation = true
  availability_zone_id = each.value
  cidr_block = cidrsubnet(
    local.cidr_map[1],  var.cidr_subnit_bits, index(
      data.aws_availability_zones.available.zone_ids, each.key
    )
  )
  ipv6_cidr_block = cidrsubnet(
    local.ipv6_cidr_map[1], 8 - var.ipv6_cidr_map_bits, index(
      data.aws_availability_zones.available.zone_ids, each.key
    )
  )

  tags = {
    Name = "${terraform.workspace}_private_${each.key}"
    env  = "${terraform.workspace}"
    Tier = "Private"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

output "vpc_id" {
  value = "${ aws_vpc.vpc }"
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}
output "private_subnets" {
  value = aws_subnet.private_subnets
}
