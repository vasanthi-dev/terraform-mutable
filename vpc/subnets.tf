resource "aws_subnet" "main" {
  count      = length(var.SUBNETS)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.SUBNETS,count.index )

  tags = {
    Name = "subnet-${count.index}"
  }
}