terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.62.0"
    }
  }
  required_version = "~> 1.15.8"
}


resource "aws_s3_bucket" "environments" {
  bucket = "environment-metadata"

}

resource "aws_s3_bucket_versioning" "environments" {
  bucket = aws_s3_bucket.environments.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_object" "env_metadata" {
  bucket = "environment-metadata"
  #key     = "test/metadata.json"
  key = "${var.env_name}/metadata.json"
  content = jsonencode({
    name         = var.env_name
    created_at   = timestamp()
    owner        = var.owner
    applications = var.applications
  })
  depends_on = [aws_s3_bucket.environments]
} 