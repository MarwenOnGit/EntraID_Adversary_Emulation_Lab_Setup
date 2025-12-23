terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # Credentials resolved via environment, AWS CLI config (~/.aws/credentials), or AWS_PROFILE
}

# Example S3 backend (uncomment and configure for remote state):
#
# terraform {
#   backend "s3" {
#     bucket = "your-terraform-state-bucket"
#     key    = "redteam/terraform.tfstate"
#     region = "us-east-1"
#     encrypt = true
#     dynamodb_table = "terraform-locks"
#   }
# }
