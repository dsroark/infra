provider "aws" {
    region = "${var.aws_region}"
    profile = "${var.aws_profile}"
}

#----- VPC -----------

resource "aws_vpc" "vpn_vpc" {
    cidr_block  = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.env}_vpn_vpc"
		env  = "${var.env}"
    }
}

# internet gateway

resource "aws_internet_gateway" "vpn_internet_gateway" {
    vpc_id = "${aws_vpc.vpn_vpc.id}"

    tags = {
        Name = "${var.env}_vpn_igw"
		env  = "${var.env}"
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
        Name = "${var.env}_vpn_public"
		env  = "${var.env}"
    }
}

#subnets

resource "aws_subnet" "vpn_public1_subnet" {
    vpc_id = "${aws_vpc.vpn_vpc.id}"
    cidr_block  = "${var.cidrs["public1"]}"
    map_public_ip_on_launch = true
    availability_zone = "${data.aws_availability_zones.available.names[0]}"

    tags = {
        Name = "${var.env}_vpn_public1"
		env = "${var.env}"
    }
}

# Subnet associations

resource "aws_route_table_association" "vpn_public1_assoc" {
  subnet_id      = "${aws_subnet.vpn_public1_subnet.id}"
  route_table_id = "${aws_route_table.vpn_public_rt.id}"
}

#------------------- Security Groups --------------------

resource "aws_security_group" "vpn_sg" {
  name        = "${var.env}_vpn_sg"
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
    from_port   = 1194
    to_port     = 1194
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

resource "aws_network_interface" "vpn" {
  subnet_id   = "${aws_subnet.vpn_public1_subnet.id}"
  security_groups = ["${aws_security_group.vpn_sg.id}"]

  tags = {
    Name = "${var.env}_vpn_interface"
    env  = "${var.env}"
  }
}

resource "aws_network_interface" "ca" {
  subnet_id   = "${aws_subnet.vpn_public1_subnet.id}"
  security_groups = ["${aws_security_group.vpn_sg.id}"]

  tags = {
    Name = "${var.env}_vpn_interface"
    env  = "${var.env}"
  }
}

resource "aws_instance" "vpn" {
    ami                  = "${data.aws_ami.ubuntu.id}"
    instance_type        = "t2.nano"

    key_name             = "${aws_key_pair.vpn_access.id}"
    user_data            = "${file("userdata")}"

    network_interface {
      network_interface_id = "${aws_network_interface.vpn.id}"
      device_index         = 0
    }

    tags = {
        Name = "${var.env}_${var.vpn_instance_name}"
        env  = "${var.env}"
        function = "vpnserver"
    }
}

resource "aws_instance" "ca" {
    ami                  = "${data.aws_ami.ubuntu.id}"
    instance_type        = "t2.nano"

    key_name             = "${aws_key_pair.vpn_access.id}"
    user_data            = "${file("userdata")}"

    network_interface {
      network_interface_id = "${aws_network_interface.ca.id}"
      device_index         = 0
    }

    tags = {
        Name = "${var.env}_${var.ca_instance_name}"
        env  = "${var.env}"
        function = "caserver"
    }
}

output "image_id" {
    value = "${data.aws_ami.ubuntu.id}"
}
