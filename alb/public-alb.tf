resource "aws_lb" "public" {
  name               = "roboshop-public-${var.ENV}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public-alb.id]
  subnets            = data.terraform_remote_state.vpc.outputs.PUBLIC_SUBNETS_IDS
  enable_deletion_protection = true

  tags = {
    Environment = "roboshop-public-${var.ENV}"
  }
}