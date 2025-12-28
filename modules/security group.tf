# Load Balancer Security Group
resource "aws_security_group" "lb" {
  name        = var.lb_sg_name
  description = "Allow HTTP/HTTPS inbound for Load Balancer"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.lb_sg_name
  }
}

# Application (Next.js) Security Group
resource "aws_security_group" "next_SG" {
  name        = var.instance_sg_name
  description = "Allow traffic from Load Balancer on port 3000"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "App port from Load Balancer"
    from_port       = var.instance_port
    to_port         = var.instance_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    description = "Allow all outbound (internet access, DB, etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.instance_sg_name
  }
}

# RDS Postgres Security Group
resource "aws_security_group" "rds_sg" {
  name        = var.db_sg_name
  description = "Security group for BSOD PostgreSQL RDS instance"
  vpc_id      = aws_vpc.my_vpc.id

  # Allow PostgreSQL from Next.js application instances
  ingress {
    description     = "PostgreSQL from Next.js instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.next_SG.id]
  }

  # Allow PostgreSQL from Bastion host (conditionally added when bastion is enabled)
  dynamic "ingress" {
    for_each = var.enable_bastion ? [1] : []
    content {
      description     = "PostgreSQL from Bastion host"
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [aws_security_group.bastion_sg[0].id]
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.db_sg_name
  }
}

# Bastion Host Security Group (only created when bastion is enabled)
resource "aws_security_group" "bastion_sg" {
  count       = var.enable_bastion ? 1 : 0
  name        = "BSOD-Bastion-SG"
  description = "Allow SSH access to bastion host"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH from allowed IP range"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ssh_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BSOD-Bastion-SG"
  }
}