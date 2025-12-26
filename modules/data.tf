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

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }

  # Optional: explicit dependency to ensure order
  depends_on = [aws_vpc.my_vpc]
}

data "aws_subnets" "alb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Type"
    values = ["Public"]
  }

  filter {
    name   = "availability-zone"
    values = var.bsod_availability_zones
  }

  depends_on = [aws_subnet.public]
}

data "aws_subnets" "asg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Type"
    values = ["Private"]
  }

  filter {
    name   = "availability-zone"
    values = var.bsod_availability_zones
  }

  depends_on = [aws_subnet.private]
}