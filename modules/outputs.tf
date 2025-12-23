output "launch_template_id" {
  value = aws_launch_template.bsod_template.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.bsod_template.latest_version
}

output "used_ami_id" {
  description = "The AMI ID that was actually used (for verification)"
  value       = data.aws_ami.bsod_base.id
}

output "attached_security_group_id" {
  description = "Security group attached to instances via the launch template"
  value       = aws_security_group.next_SG.id
}

output "target_group_arn" {
  value       = aws_lb_target_group.main.arn
  description = "ARN of the target group"
}

output "target_group_name" {
  value       = aws_lb_target_group.main.name
  description = "Name of the target group"
}

output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ARN of the Application Load Balancer"
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the ALB (use in Route53 or directly)"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "AZ ID for the ALB"
}

output "rds_endpoint" {
  value       = aws_db_instance.bsod_db.endpoint
  description = "The endpoint (hostname:port) of the RDS instance"
}

output "rds_master_username" {
  value       = aws_db_instance.bsod_db.username
  description = "Master username"
}

output "db_master_secret_arn" {
  value       = aws_db_instance.bsod_db.master_user_secret[0].secret_arn
  description = "ARN of the Secrets Manager secret containing the auto-generated password"
  sensitive   = true
}

output "db_master_secret_name" {
  value       = replace(aws_db_instance.bsod_db.master_user_secret[0].secret_arn, "/.*secret:/", "")
  description = "Clean name of the Secrets Manager secret"
}

output "ec2_role_name" {
  value       = aws_iam_role.ec2_app_role.name
  description = "IAM role attached to EC2 instances"
}

output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_app_profile.name
  description = "Instance profile used in launch template"
}