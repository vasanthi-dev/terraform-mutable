resource "aws_lb" "private" {
  name               = "roboshop-private-${var.ENV}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private-alb.id]
  subnets            = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS_IDS
  enable_deletion_protection = false

  tags = {
    Environment = "roboshop-private-${var.ENV}"
  }
}