data "terraform_remote_state" "vpc" {

  backend = "s3"
  config = {
    bucket = "terraform-dev60"
    key    = "terraform-mutable/vpc/${var.ENV}/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_secretsmanager_secret" "secrets" {
  name = var.ENV
}

data "aws_secretsmanager_secret_version" "secrets-version" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

#output "sec" {
#  value = data.aws_secretsmanager_secret_version.secrets-version
#}

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "echo ${jsondecode(data.aws_secretsmanager_secret_version.secrets-version)["RDS_MYSQL_USER"]} >/TMP/1"
  }
}
