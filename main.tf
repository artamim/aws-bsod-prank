terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "web_app_1" {
  source = "./modules"

  ec2_role_name             = "AWSEC2SecretsAndRDSPostgresReadOnly"
  ec2_instance_profile_name = "AWSEC2SecretsAndRDSPostgresReadOnlyProfile"
  region                    = "ap-south-1"
  vpc_name                  = "BSOD-vpc"
  launch_template_name      = "BSODTemplate"
  instance_type             = "t3.small"
  root_volume_size          = 8
  instance_sg_name          = "BSOD-Instance-SG"
  db_sg_name                = "BSOD-DB-SG"
  lb_sg_name                = "BSOD-ALB-SG"
  target_group_name         = "BSOD-Target-Group"
  instance_port             = 3000
  health_check_path         = "/api/health"
  tags                      = { Environment = "Staging" }
  alb_availability_zones    = ["ap-south-1b", "ap-south-1c"]
  asg_availability_zones    = ["ap-south-1b", "ap-south-1c"]
  db_identifier             = "bsod-db"
  master_username           = "Tamim"
  initial_db_name           = "Test1"
  db_availability_zone      = "ap-south-1b"
}