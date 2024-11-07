terraform {
  backend "s3" {
    bucket = "udacity-tf-tscotto-us-east" #var.bucket_name # Update here with your S3 bucket #
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = local.tags
  }
}

# variable "bucket_name" {
#   description = "The name of the S3 bucket"
#   type        = string
# }