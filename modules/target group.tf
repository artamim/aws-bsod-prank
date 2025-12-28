resource "aws_lb_target_group" "main" {
  name            = var.target_group_name
  port            = var.instance_port
  protocol        = var.protocol
  vpc_id          = aws_vpc.my_vpc.id
  target_type     = var.target_type
  ip_address_type = var.ip_address_type

  health_check {
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout
    interval            = var.interval
    path                = var.health_check_path
    matcher             = var.matcher
  }

  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : []
    content {
      type            = "lb_cookie"
      cookie_duration = 86400
      enabled         = true
    }
  }

  tags = var.tags
}