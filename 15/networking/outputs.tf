output "private_subnet_id" {
  value = aws_subnet.hillel-demo-private-subnet.id
}

output "public_subnet_id" {
  value = aws_subnet.hillel-demo-public-subnet.id
}