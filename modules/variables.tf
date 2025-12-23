variable "vpc_name" {
  description = "Name tag of the VPC to use (e.g., 'default' or 'BSOD-vpc')"
  type        = string
  default     = "BSOD-vpc" # Changed to match your setup
}

variable "lb_sg_name" {
  description = "Name (and tag Name) of the Load Balancer security group"
  type        = string
  default     = "ALB-SG" # Updated to match main.tf override
}

variable "instance_sg_name" {
  description = "Name (and tag Name) of the Application (Next.js) security group"
  type        = string
  default     = "Instance-SG" # Updated to match main.tf override
}

variable "db_sg_name" {
  description = "Name (and tag Name) of the Application (Next.js) security group"
  type        = string
  default     = "DB-SG" # Updated to match main.tf override
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small" # Updated to match main.tf override
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 8 # Updated to match main.tf override
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the instances"
  type        = string
  default     = "AWSEC2SecretsReadOnly" # Updated to match main.tf
}

variable "launch_template_name" {
  description = "Launch template name for instances creation"
  type        = string
  default     = "BSODTemplate" # Updated to match main.tf
}

variable "target_group_name" {
  description = "Target group name"
  type        = string
  default     = "BSOD-Target-Group" # Updated to match main.tf
}

variable "instance_port" {
  description = "Port on which instances listen (Next.js app port)"
  type        = number
  default     = 3000 # Updated to match main.tf (Next.js default)
}

variable "target_type" {
  description = "Target type of the target group (instance/ip/lambda/alb)"
  type        = string
  default     = "instance"
}

variable "protocol" {
  description = "Protocol for the target group and listener"
  type        = string
  default     = "HTTP"
}

variable "ip_address_type" {
  description = "IP address type for the target group"
  type        = string
  default     = "ipv4"
}

variable "healthy_threshold" {
  description = "Number of consecutive health check successes required"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 5
}

variable "timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 10
}

variable "health_check_path" {
  description = "Destination for the health check request"
  type        = string
  default     = "/"
}

variable "matcher" {
  description = "HTTP codes to use when checking for a successful response"
  type        = string
  default     = "200"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "BSOD"
  }
}

variable "alb_availability_zones" {
  description = "List of AZs for the ALB subnets"
  type        = list(string)
  default     = ["ap-south-1b", "ap-south-1c"]
}

variable "asg_availability_zones" {
  description = "List of AZs for the ASG subnets"
  type        = list(string)
  default     = ["ap-south-1b", "ap-south-1c"]
}

variable "db_identifier" {
  type        = string
  description = "RDS instance identifier"
  default     = "bsod-db"
}

variable "master_username" {
  type        = string
  description = "Master username for the database"
  default     = "Tamim"
}

variable "initial_db_name" {
  type        = string
  description = "Initial database name"
  default     = "Test1"
}

variable "db_availability_zone" {
  type        = string
  description = "Availability zone for the RDS instance"
  default     = "ap-south-1b"
}

variable "region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "ap-south-1"
}

variable "ec2_role_name" {
  description = "Name of the IAM role for EC2 instances"
  type        = string
  default     = "AWSEC2SecretsAndRDSPostgresReadOnly"
}

variable "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
  default     = "AWSEC2SecretsAndRDSPostgresReadOnlyProfile"
}