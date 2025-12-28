# DB Subnet Group - uses only private subnets in your chosen AZs
# Since you're limiting to single AZ deployment, we'll filter to one AZ if needed
resource "aws_db_subnet_group" "bsod" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = data.aws_subnets.asg.ids

  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }

  depends_on = [aws_subnet.private]
}

resource "aws_db_instance" "bsod_db" {
  identifier     = var.db_identifier
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro" # ← Free tier eligible (t3.micro, not t4g in all regions)
  # Use db.t3.micro — it's free tier eligible in ap-south-1
  # db.t4g.micro may not be free tier in all regions

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2" # gp2 is free tier default; gp3 has minor extra cost sometimes

  publicly_accessible = false # ← Secure: no public access

  # Single AZ placement
  availability_zone = var.db_availability_zone # e.g., "ap-south-1b" — you control it

  db_subnet_group_name   = aws_db_subnet_group.bsod.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  username                    = var.master_username
  manage_master_user_password = true
  db_name                     = var.initial_db_name

  iam_database_authentication_enabled = true

  # Free-tier safe backup settings
  backup_retention_period  = 0    # 0 days = no automated backups (free, but risky)
  skip_final_snapshot      = true # No final snapshot on destroy (free)
  delete_automated_backups = true

  apply_immediately = true

  tags = {
    Name = var.db_identifier
  }

  depends_on = [
    aws_db_subnet_group.bsod,
    aws_security_group.rds_sg
  ]
}