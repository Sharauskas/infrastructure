resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.project}-${var.group}-vpc-${var.env}"
    Environment = var.env
    Group       = var.group
  }
}

# Create multi azs subnets for ELB
resource "aws_subnet" "public_subnet" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  depends_on              = [aws_vpc.main]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.group}-${var.env}-${count.index + 1}"
    Group = var.group
    Tier  = "Public"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}