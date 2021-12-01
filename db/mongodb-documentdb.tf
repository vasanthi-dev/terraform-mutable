locals {
  mongo_user = jsondecode(data.aws_secretsmanager_secret_version.secrets-version.secret_string)["DOCDB_MONGO_USER"]
  mongo_pass = jsondecode(data.aws_secretsmanager_secret_version.secrets-version.secret_string)["DOCDB_MONGO_PASS"]
}
resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "mongodb-${var.ENV}"
  engine                  = "docdb"
  engine_version          = "4.0.0"
  master_username         = local.mongo_user
  master_password         = local.mongo_pass
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_docdb_subnet_group.docdb.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.pg.name
  vpc_security_group_ids = [aws_security_group.mongodb.id]
}

resource "aws_docdb_subnet_group" "docdb" {
  name       = "mongodb-subnet-group-${var.ENV}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS_IDS

  tags = {
    Name = "mongodb-subnet-group-${var.ENV}"
  }
}

resource "aws_docdb_cluster_parameter_group" "pg" {
  family      = "docdb4.0"
  name        = "mongodb-parameter-group-${var.ENV}"
  description = "mongodb-parameter-group-${var.ENV}"
}


resource "aws_security_group" "mongodb" {
  name        = "mongodb-${var.ENV}"
  description = "mongodb-${var.ENV}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress = [
    {
      description      = "MONGODB"
      from_port        = 27017
      to_port          = 27017
      protocol         = "tcp"
      cidr_blocks      = local.ALL_CIDR
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "mongodb-${var.ENV}"
  }
}
