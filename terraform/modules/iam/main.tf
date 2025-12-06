# -----------------------------
# IAM Role for EC2
# -----------------------------
resource "aws_iam_role" "ec2_role" {
  name = "assignment-ec2-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# -----------------------------
# IAM Policy for S3 + SSM + Logs
# -----------------------------
resource "aws_iam_policy" "ec2_policy" {
  name = "assignment-ec2-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # -------- S3 GET -----------
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket}/*"
      },

      # -------- CloudWatch Logs --------
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },

      # -------- SSM Session Manager --------
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeInstanceInformation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2messages:GetMessages",
          "ec2messages:GetEndpoint",
          "ec2messages:PutMessages",
          "ec2messages:AcknowledgeMessage"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------
# Attach Policy → Role
# -----------------------------
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# -----------------------------
# Instance Profile for EC2
# -----------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "assignment-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}
