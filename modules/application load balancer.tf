resource "aws_lb" "main" {
  name               = "BSOD-ALB"
  internal           = false # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = data.aws_subnets.alb.ids
  ip_address_type    = "ipv4"

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}