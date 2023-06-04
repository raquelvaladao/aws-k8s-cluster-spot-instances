resource "aws_vpc" "k8s-vpc" {
  cidr_block           = var.vpc_range
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.k8s-vpc.id
  availability_zone       = var.public_subnets[count.index].az
  cidr_block              = var.public_subnets[count.index].range
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-subnet-public-${var.public_subnets[count.index].az}-${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.k8s-vpc.id

  availability_zone = var.private_subnets[count.index].az
  cidr_block        = var.private_subnets[count.index].range

  tags = {
    Name = "k8s-subnet-private-${var.private_subnets[count.index].az}-${count.index}"
  }
}

resource "aws_route_table" "private_route_tables" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Name = "private-rt-${var.private_subnets[count.index].az}"
  }
}

resource "aws_route_table_association" "private_subnets_route_tables_association" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.k8s-vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = [aws_vpc.k8s-vpc]
  gateway_id             = aws_internet_gateway.gw.id
}