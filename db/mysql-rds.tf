#resource "aws_db_instance" "mysql" {
#  allocated_storage    = 10
#  engine               = "mysql"
#  engine_version       = "5.7"
#  instance_class       = "db.t3.micro"
#  name                 = "dummy"
#  username             = "vadmin"
#  password             = "vadmin"
#  parameter_group_name = aws_db_parameter_group.pg.name
#  skip_final_snapshot  = true
#}
#
#resource "aws_db_parameter_group" "pg" {
#  name   = "mysql-${var.ENV}-pg"
#  family = "mysql5.7"
#}

#resource "aws_db_subnet_group" "subnet-group" {
#  name       = "main"
#  subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]
#
#  tags = {
#    Name = "My DB subnet group"
#  }
#}

output "PRIVATE_SUBNETS" {
  value = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS_IDS
}