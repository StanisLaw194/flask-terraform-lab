terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "flask-lab-tfstate-stanislaw194"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "flask-lab-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}
