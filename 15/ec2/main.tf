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
  instance_type = var.public_instance_type
  subnet_id     = var.public_subnet_id
  tags = {
    Name = "AmazonEC2-public"
  }

}
#12 Create EC2 instance in private subnet

resource "aws_instance" "private-instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.private_instance_type
  subnet_id     = var.private_subnet_id

  tags = {
    Name = "AmazonEC2-private"
  }

}