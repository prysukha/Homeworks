provider "aws" {
  region     = "us-east-2"
  access_key = "xxxxxxxxxxxx"
  secret_key = "yyyyyyyyyyyy"
}

#1 Create a VPC
resource "aws_vpc" "hillel-demo-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My_HillelVPC"
  }
}

#2 Create a public subnet

resource "aws_subnet" "hillel-demo-public-subnet" {
  vpc_id     = aws_vpc.hillel-demo-vpc.id
  cidr_block = "10.0.1.0/24"
}

#3 Create privat subnet

resource "aws_subnet" "hillel-demo-privat-subnet" {
  vpc_id     = aws_vpc.hillel-demo-vpc.id
  cidr_block = "10.0.101.0/24"
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
  subnet_id     = aws_subnet.hillel-demo-privat-subnet.id
}

#7 route tables for public subnet

resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.hillel-demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
}

#8 route tables for privat subnet

resource "aws_route_table" "PrivatRT" {
  vpc_id     = aws_vpc.hillel-demo-vpc.id
  depends_on = [aws_nat_gateway.nat_gateway]
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  route {
    cidr_block = "10.0.0.0/16"
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
  subnet_id      = aws_subnet.hillel-demo-privat-subnet.id
  route_table_id = aws_route_table.PrivatRT.id
}

#11 Create EC2 instance in public subnet

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "public-instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.hillel-demo-public-subnet.id

  tags = {
    Name = "AmazonEC2-public"
  }

}
#12 Create EC2 instance in public subnet

resource "aws_instance" "private-instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.hillel-demo-privat-subnet.id

  tags = {
    Name = "AmazonEC2-privat"
  }

}