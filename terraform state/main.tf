provider "aws" {
  region = "us-east-2"
}
resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-state-karam"
   /*
    lifecycle {
      prevent_destroy = true
    }*/
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
resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-karam-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "the ARN of the S3 bucket"
}
output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.arn
    description = "the name of the dyanamoDB table"
}