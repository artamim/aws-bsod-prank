data "aws_vpc" "selected" {
  default = true
}

data "aws_ami" "bsod_base" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["BSOD-Frontend-Base-AMI"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_subnets" "alb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "availability-zone"
    values = var.alb_availability_zones
  }
}