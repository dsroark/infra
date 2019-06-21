provider "aws" {
    region = "${var.aws_region}"
    profile = "${var.aws_profile}"
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

#----- VPC -----------

resource "aws_vpc" "vpn_vpc" {
    cidr_block  = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "vpn_vpc"
    }
}

# internet gateway

resource "aws_internet_gateway" "vpn_internet_gateway" {
    vpc_id = "${aws_vpc.vpn_vpc.id}"

    tags = {
        Name = "vpn_igw"
    }
}

# route tables


resource "aws_route_table" "vpn_public_rt" {
    vpc_id = "${aws_vpc.vpn_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.vpn_internet_gateway.id}"
    }
    tags = {
        Name = "vpn_public"
    }
}

#subnets

resource "aws_subnet" "vpn_public1_subnet" {
    vpc_id = "${aws_vpc.vpn_vpc.id}"
    cidr_block  = "${var.cidrs["public1"]}"
    map_public_ip_on_launch = true
    availability_zone = "${data.aws_availability_zones.available.names[0]}"

    tags = {
        Name = "vpn_public1"
    }
}

# Subnet associations

resource "aws_route_table_association" "vpn_public1_assoc" {
  subnet_id      = "${aws_subnet.vpn_public1_subnet.id}"
  route_table_id = "${aws_route_table.vpn_public_rt.id}"
}

#------------------- Security Groups --------------------

resource "aws_security_group" "vpn_sg" {
  name        = "vpn_dev_sg"
  description = "Used for access to the dev instance"
  vpc_id      = "${aws_vpc.vpn_vpc.id}"

  #ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }
  ingress {
    from_port   = 1193
    to_port     = 1193
    protocol    = "udp"
    cidr_blocks = ["${var.localip}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#-------------- keys -----------------

resource "aws_key_pair" "vpn_access" {
  key_name   = "vpn_access"
  public_key = "${var.pubkey}"
}

#-------------- instances -------------


resource "aws_instance" "vpn-dev" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.nano"

    key_name = "${aws_key_pair.vpn_access.id}"
    security_groups = ["${aws_security_group.vpn_sg.id}"]
    user_data       = "${file("userdata")}"

    tags = {
        Name = "dsrvpn_dev"
        env  = "dev"
        function = "openvpn"
    }
}

resource "aws_instance" "vpn-prod" {
    ami             = "${data.aws_ami.ubuntu.id}"
    instance_type   = "t2.nano"

    key_name        = "${aws_key_pair.vpn_access.id}"
    security_groups = ["${aws_security_group.vpn_sg.id}"]
    user_data       = "${file("userdata")}"

    tags = {
        Name = "dsrvpn"
        env  = "prod"
        function = "openvpn"
    }
}


output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}
