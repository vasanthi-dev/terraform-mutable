resource "aws_vpc_peering_connection" "foo" {
  peer_vpc_id   = aws_vpc.main.id
  vpc_id        = var.DEFAULT_VPC_ID
}