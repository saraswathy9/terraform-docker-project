# This file tells Terraform what to create on AWS.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Which AWS region to use
provider "aws" {
  region = var.aws_region
}

# A firewall rule (security group) â€” allows website traffic (port 80)
# and SSH access (port 22)
resource "aws_security_group" "web_sg" {
  name        = "docker-web-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The actual server (EC2 instance)
resource "aws_instance" "docker_web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # This script runs automatically when the server starts.
  # It installs Docker and starts our website container.
  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "terraform-docker-webserver"
  }
}

# Prints the server's public IP after it's created
output "public_ip" {
  value = aws_instance.docker_web.public_ip
}
