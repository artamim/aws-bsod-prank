locals {
  security_group_ids = [aws_security_group.next_SG.id]
}

resource "aws_launch_template" "bsod_template" {
  name_prefix   = "${var.launch_template_name}-"
  image_id      = data.aws_ami.bsod_base.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_app_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = local.security_group_ids
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "BSOD-Frontend-Instance"
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    # Install required tools
    yum install -y jq perl

    # Wait for RDS to be available
    until aws rds describe-db-instances --db-instance-identifier ${var.db_identifier} \
      --region ${var.region} \
      --query "DBInstances[0].DBInstanceStatus" --output text 2>/dev/null | grep -q "available"; do
      echo "Waiting for RDS to become available..."
      sleep 20
    done

    cd /home/ec2-user/BSOD-Frontend
    npm install -g pm2
    # Pull latest code
    sudo -u ec2-user git fetch origin
    sudo -u ec2-user git reset --hard origin/main

    # Clean old build artifacts (critical for Server Actions)
    sudo -u ec2-user rm -rf .next

    # Install dependencies and build
    sudo -u ec2-user npm ci
    sudo -u ec2-user npm run build

    # Fetch database password from Secrets Manager
    DB_SECRET_ARN="${aws_db_instance.bsod_db.master_user_secret[0].secret_arn}"
    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --secret-id "$DB_SECRET_ARN" \
      --region ${var.region} \
      --query SecretString --output text)

    DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r .password)

    # URL-encode the password to handle special characters safely
    ENCODED_PASSWORD=$(printf '%s' "$DB_PASSWORD" | perl -MURI::Escape -ne 'print uri_escape($_)')

    # Construct correct DATABASE_URL using the full RDS endpoint (includes :5432)
    DATABASE_URL="postgresql://${var.master_username}:$ENCODED_PASSWORD@${aws_db_instance.bsod_db.endpoint}/${var.initial_db_name}?schema=public&sslmode=require"
    export DATABASE_URL

    # Apply Prisma migrations
    sudo -u ec2-user DATABASE_URL="$DATABASE_URL" npx prisma migrate deploy

    # Clean up any old PM2 processes
    pm2 delete next-app 2>/dev/null || true

    # Start the Next.js app
    DATABASE_URL="$DATABASE_URL" pm2 start npm --name "next-app" -- start -- -p 3000

    # Configure PM2 to start on boot
    sudo -u ec2-user pm2 save
    sudo -u ec2-user pm2 startup systemd -u ec2-user --hp /home/ec2-user

    echo "BSOD Frontend deployed and running successfully!"
  EOF
  )

  tags = {
    Name = var.launch_template_name
  }

  depends_on = [
    aws_security_group.next_SG,
    aws_db_instance.bsod_db,
    aws_iam_instance_profile.ec2_app_profile
  ]
}