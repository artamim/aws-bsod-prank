# modules/iam.tf

# Trust policy for EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create the IAM role with configurable name
resource "aws_iam_role" "ec2_app_role" {
  name               = var.ec2_role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = var.ec2_role_name
  }
}

# Attach Secrets Manager client read-only policy (the one from your screenshot)
resource "aws_iam_role_policy_attachment" "secrets_read" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"
}

# Attach RDS read-only policy (for describe-db-instances in wait loop)
resource "aws_iam_role_policy_attachment" "rds_read" {
  role       = aws_iam_role.ec2_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

# Create instance profile with configurable name
resource "aws_iam_instance_profile" "ec2_app_profile" {
  name = var.ec2_instance_profile_name
  role = aws_iam_role.ec2_app_role.name
}