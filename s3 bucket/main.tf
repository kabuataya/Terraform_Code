provider "aws" {
  region = "us-east-2"
}
resource "aws_s3_bucket" "AWS_Bucket" {
    bucket = "${var.bucket_name}-vRA"
    versioning {
      enabled = true
    }
    server_side_encryption_configuration {
      rule {
          apply_server_side_encryption_by_default {
              sse_algorithm = "AES256"
          }
      }
    }
}
output "s3_bucket_arn" {
    value = aws_s3_bucket.AWS_Bucket.arn
    description = "the ARN of the S3 bucket"
}
