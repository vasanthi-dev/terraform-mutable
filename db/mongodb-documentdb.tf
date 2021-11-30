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
}