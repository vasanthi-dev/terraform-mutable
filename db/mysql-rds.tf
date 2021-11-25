locals {
  rds_user = jsondecode(data.aws_secretsmanager_secret_version.secrets-version.secret_string)["RDS_MYSQL_USER"]
  rds_pass = jsondecode(data.aws_secretsmanager_secret_version.secrets-version.secret_string)["RDS_MYSQL_PASS"]
}
resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  identifier           = "mysql-${var.ENV}"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "dummy"
  username             = rds_user
  password             = rds_pass
  parameter_group_name = aws_db_parameter_group.pg.name
  skip_final_snapshot  = true
}

resource "aws_db_parameter_group" "pg" {
  name   = "mysql-${var.ENV}-pg"
  family = "mysql5.7"
}

resource "aws_db_subnet_group" "subnet-group" {
  name       = "mysqldb-subnet-group-${var.ENV}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS_IDS

  tags = {
    Name = "mysqldb-subnet-group-${var.ENV}"
  }
}

resource "aws_route53_record" "mysql" {
  zone_id = data.terraform_remote_state.vpc.outputs.INTERNAL_HOSTED_ZONE_ID
  name    = "mysql-${var.ENV}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.mysql.endpoint]
}

resource "null_resource" "schema-apply" {
  provisioner "local-exec" {
    command=<<EOF
sudo yum install mariadb -y
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
cd /tmp
unzip -o /tmp/mysql.zip
mysql -h${aws_db_instance.mysql.address} -u${local.rds_user} -p${local.rds_pass} <mysql-main/shipping.sql
EOF
  }
}