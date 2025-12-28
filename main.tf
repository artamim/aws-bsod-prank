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
  vpc_name                  = "BSOD-VPC"
  launch_template_name      = "BSODTemplate"
  instance_type             = "t3.small"
  root_volume_size          = 8
  instance_sg_name          = "BSOD-Instance-SG"
  db_sg_name                = "BSOD-DB-SG"
  lb_sg_name                = "BSOD-ALB-SG"
  target_group_name         = "BSOD-Target-Group"
  aws_asg_name              = "BSOD-ASG"
  asg_target_tracking_name  = "BSOD-ASG-TRGT-GRP"
  instance_port             = 3000
  health_check_path         = "/api/health"
  tags                      = { Environment = "Staging" }
  bsod_availability_zones   = ["ap-south-1b", "ap-south-1c", "ap-south-1a"]
  db_identifier             = "bsod-db"
  master_username           = "Tamim"
  initial_db_name           = "Test1"
  db_availability_zone      = "ap-south-1b"
  enable_bastion            = true
  bastion_key_name          = "BSOD-Bastion-Key" # Must exist in ap-south-1
  # bastion_ssh_cidr   = "YOUR.IP.ADDRESS/32"     Strongly recommended
  enable_stickiness          = true
}