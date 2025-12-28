data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  ami                         = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.bastion_instance_type
  subnet_id                   = data.aws_subnets.alb.ids[0]  # First public subnet
  associate_public_ip_address = true
  key_name                    = var.bastion_key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg[0].id]

  iam_instance_profile        = aws_iam_instance_profile.ec2_app_profile.name

  tags = {
    Name        = "BSOD-Bastion"
    Environment = "Staging"
    Project     = "BSOD"
  }

  # Install PostgreSQL client and create a handy psql-bsod alias
  user_data = <<-EOF
    #!/bin/bash

    # Update and install PostgreSQL 16 client + jq (needed for password extraction)
    dnf update -y
    dnf install -y postgresql16 jq

    # Create the psql-bsod alias for ec2-user
    cat << 'ALIAS' >> /home/ec2-user/.bashrc

    # Alias to connect to the BSOD PostgreSQL database
    alias psql-bsod='psql "host=$(aws rds describe-db-instances --db-instance-identifier bsod-db --query "DBInstances[0].Endpoint.Address" --output text) \
      port=5432 \
      dbname=Test1 \
      user=Tamim \
      password=$(aws secretsmanager get-secret-value \
                  --secret-id $(aws rds describe-db-instances --db-instance-identifier bsod-db --query "DBInstances[0].MasterUserSecret.SecretArn" --output text) \
                  --query SecretString --output text | jq -r .password) \
      sslmode=require"'
    ALIAS

    # Ensure correct ownership
    chown ec2-user:ec2-user /home/ec2-user/.bashrc

    echo "Bastion setup complete: psql-bsod alias created."
  EOF

  depends_on = [
    aws_security_group.bastion_sg
  ]
}

# Outputs
output "bastion_public_ip" {
  description = "Public IP address of the bastion host (null if bastion not enabled)"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_ip : null
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].id : null
}