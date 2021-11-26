locals {
  rds_user = jsondecode(data.aws_secretsmanager_secret_version.secrets-version.secret_string)["RDS_MYSQL_USER"]
  rds_pass = jsondecode(data.aws_secretsmanager_secret_version.secrets-version.secret_string)["RDS_MYSQL_PASS"]
  DEFAULT_VPC_CIDR = split(",", data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR )
  ALL_CIDR = concat(data.terraform_remote_state.vpc.outputs.ALL_VPC_CIDR, local.DEFAULT_VPC_CIDR)
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
  vpc_security_group_ids = []
}

#resource "aws_db_security_group" "mysql" {
#  name = "mysql-${var.ENV}"
#
#  dynamic "ingress" {
#    for_each =
#    content {
#      cidr = ingress.value
#    }
#  }
#}

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
  depends_on = [aws_route53_record.mysql]
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