terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.62.0"
    }
  }
  required_version = "~> 1.15.8"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "cluster_vpc" {
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "az1" {
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "az2" {
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "az3" {
  vpc_id            = aws_vpc.cluster_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
}

resource "aws_security_group" "cluster_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for the EKS cluster"
  vpc_id      = aws_vpc.cluster_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.cluster_sg.id
  cidr_ipv4         = aws_vpc.cluster_vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
  security_group_id = aws_security_group.cluster_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

/* resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv6" {
  security_group_id = aws_security_group.cluster_sg.id
  cidr_ipv6 = aws_vpc.cluster_vpc.ipv6_cidr_block
  from_port = 443
  ip_protocol = "tcp"
  to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv6" {
 security_group_id = aws_security_group.cluster_sg.id
 cidr_ipv6 = "::/0"
 ip_protocol = "-1"
} */