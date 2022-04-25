provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 1.1.0"
}

resource "aws_s3_bucket" "neocdtv_terraform_state" {
  bucket = "neocdtv-terraform-state-v2"
}

resource "aws_s3_bucket_versioning" "versioning_neocdtv_terraform_state" {
  bucket = aws_s3_bucket.neocdtv_terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "neocdtv-terraform-state-v2-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"  
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "neocdtv-terraform-state-v2"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "neocdtv-terraform-state-v2-locks"
    encrypt        = true
  }
}

