resource "aws_db_instance" "bsod_db" {
  identifier            = var.db_identifier
  engine                = "postgres"
  engine_version        = "16"
  instance_class        = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  publicly_accessible = true
  availability_zone   = var.db_availability_zone

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  username                    = var.master_username
  manage_master_user_password = true
  db_name                     = var.initial_db_name

  iam_database_authentication_enabled = true

  backup_retention_period  = 0
  skip_final_snapshot      = true
  delete_automated_backups = true
  apply_immediately        = true

  tags = {
    Name = var.db_identifier
  }

  depends_on = [
    aws_security_group.rds_sg
  ]
}