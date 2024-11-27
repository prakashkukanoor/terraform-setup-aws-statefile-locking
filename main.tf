# Create S3 bucket with delete protection, versioning, and encryption enabled
locals {
  policies = jsondecode(templatefile("${var.path_to_json_file}", {
    bucket_name         = var.bucket_name
  }))
  
  common_tags = {
    environment = var.environment
    owner       = var.team
    createdBy   = "terraform"
  }

}

# Create s3 bucket
resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}" # Replace with your bucket name

  tags = local.common_tags
}

# Block public access settings
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Attach iam policy to the s3
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode(local.policies.policy_statement)

}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "${var.dynamodb_table_name}"
  billing_mode   = "PAY_PER_REQUEST" # On-demand billing mode for simplicity
  hash_key       = "LockID"          # Primary key for the table

  attribute {
    name = "LockID"
    type = "S" # String type
  }

  tags = local.common_tags
}