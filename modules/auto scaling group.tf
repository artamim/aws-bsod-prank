resource "aws_autoscaling_group" "bsod" {
  name                = var.aws_asg_name
  vpc_zone_identifier = data.aws_subnets.asg.ids

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  health_check_type         = "ELB" # Uses ALB health checks
  health_check_grace_period = 300   # Time for app to start (Next.js build can take a bit)

  launch_template {
    id      = aws_launch_template.bsod_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.main.arn]

  # Balanced distribution across AZs
  default_cooldown      = 300
  placement_group       = null
  protect_from_scale_in = false
}

# Target Tracking Scaling Policy - CPU Utilization
resource "aws_autoscaling_policy" "cpu_tracking" {
  name                   = var.asg_target_tracking_name
  autoscaling_group_name = aws_autoscaling_group.bsod.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = 50.0
    disable_scale_in = false
  }
}