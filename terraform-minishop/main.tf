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

variable "catalog_image" {
  description = "Registered Lightsail image for the catalog service"
  type        = string
}

variable "order_image" {
  description = "Registered Lightsail image for the order service"
  type        = string
}

resource "aws_lightsail_container_service" "minishop" {
  name  = "minishop-lab"
  power = "nano"
  scale = 1

  tags = {
    Name = "minishop-lab"
  }
}

resource "aws_lightsail_container_service_deployment_version" "minishop" {
  service_name = aws_lightsail_container_service.minishop.name

  container {
    container_name = "catalog"
    image          = var.catalog_image

    ports = {
      "8001" = "HTTP"
    }
  }

  container {
    container_name = "order"
    image          = var.order_image

    environment = {
      CATALOG_URL = "http://localhost:8001"
    }

    ports = {
      "8002" = "HTTP"
    }
  }

  public_endpoint {
    container_name = "order"
    container_port = 8002

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 5
      interval_seconds    = 10
      path                = "/health"
      success_codes       = "200"
    }
  }
}

output "minishop_service_name" {
  description = "Lightsail service for the MiniShop application"
  value       = aws_lightsail_container_service.minishop.name
}

output "minishop_url" {
  description = "Public base URL of the MiniShop order service"
  value       = aws_lightsail_container_service.minishop.url
}

output "minishop_docs_url" {
  description = "Interactive MiniShop API documentation"
  value       = "${trimsuffix(aws_lightsail_container_service.minishop.url, "/")}/docs"
}
