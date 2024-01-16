#1 Create a VPC
resource "aws_vpc" "hillel-demo-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "My_HillelVPC"
  }
}

#2 Create a public subnet

resource "aws_subnet" "hillel-demo-public-subnet" {
  vpc_id     = aws_vpc.hillel-demo-vpc.id
  cidr_block = var.public_subnet_cidr
}

#3 Create private subnet

resource "aws_subnet" "hillel-demo-private-subnet" {
  vpc_id     = aws_vpc.hillel-demo-vpc.id
  cidr_block = var.private_subnet_cidr
}

#4 Create IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.hillel-demo-vpc.id
}

#5 Allocate Elastic IP

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

#6 Create NAT gateway

resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.hillel-demo-private-subnet.id
}

#7 route tables for public subnet

resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.hillel-demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }
}

#8 route tables for privat subnet

resource "aws_route_table" "PrivateRT" {
  vpc_id     = aws_vpc.hillel-demo-vpc.id
  depends_on = [aws_nat_gateway.nat_gateway]
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }
}

#9 Public route table association

resource "aws_route_table_association" "public_subnet_rt_assoc" {
  subnet_id      = aws_subnet.hillel-demo-public-subnet.id
  route_table_id = aws_route_table.PublicRT.id
}

#10 Privat route table association

resource "aws_route_table_association" "private_subnet_rt_assoc" {
  subnet_id      = aws_subnet.hillel-demo-private-subnet.id
  route_table_id = aws_route_table.PrivateRT.id
}