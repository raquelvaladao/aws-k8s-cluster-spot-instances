

# --------------------------------------------------------
# OBS: At the moment I'm creating ONLY ONE NAT in AZ-A!!!
# --------------------------------------------------------


resource "aws_nat_gateway" "public_nat" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public_subnets[0].id #sa-east-1a-public

  tags = {
    Name = "private-subnet-A-NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "eip_nat" {
  vpc = true
  tags = {
    Name = "eip-nat"
  }
  depends_on = [aws_internet_gateway.gw]
}

# resource "aws_route" "private_subnet_to_nat_route" {
#   count = length(aws_route_table.private_route_tables)

#   route_table_id         = aws_route_table.private_route_tables[count.index].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.public_nat
#   depends_on             = [aws_route_table.private_route_tables]
# }
resource "aws_route" "private_subnet_to_nat_route" {
  route_table_id         = aws_route_table.private_route_tables[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public_nat.id
  depends_on             = [aws_route_table.private_route_tables]
}