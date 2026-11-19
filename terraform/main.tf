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

variable "image_uri" {
  description = "Full ECR image URI including the commit tag"
  type        = string
}

resource "aws_lightsail_container_service" "flask" {
  name  = "flask-lab"
  power = "nano"
  scale = 1

  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }

  tags = {
    Name = "flask-lab"
  }
}

resource "aws_ecr_repository_policy" "lightsail_pull" {
  repository = "flask-lab"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLightsailPull"
        Effect = "Allow"
        Principal = {
          AWS = aws_lightsail_container_service.flask.private_registry_access[0].ecr_image_puller_role[0].principal_arn
        }
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
      }
    ]
  })
}

resource "aws_lightsail_container_service_deployment_version" "flask" {
  service_name = aws_lightsail_container_service.flask.name

  container {
    container_name = "flask-app"
    image          = nginx:latest

    ports = {
      "80" = "HTTP"
    }
  }

  public_endpoint {
    container_name = "flask-app"
    container_port = 80

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 2
      interval_seconds    = 5
      path                = "/"
      success_codes       = "200"
    }
  }

  depends_on = [
    aws_ecr_repository_policy.lightsail_pull
  ]
}

output "lightsail_url" {
  description = "Public URL of the Flask application"
  value       = aws_lightsail_container_service.flask.url
}
