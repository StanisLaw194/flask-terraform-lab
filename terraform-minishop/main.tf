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
    key            = "minishop/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "flask-lab-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_lightsail_container_service" "minishop" {
  name  = "minishop-lab"
  power = "nano"
  scale = 1

  tags = {
    Name = "minishop-lab"
  }
}

output "minishop_service_name" {
  description = "Lightsail service for the MiniShop application"
  value       = aws_lightsail_container_service.minishop.name
}

output "minishop_url" {
  description = "MiniShop URL, usable after container deployment"
  value       = aws_lightsail_container_service.minishop.url
}
