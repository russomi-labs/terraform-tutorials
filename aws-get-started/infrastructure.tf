terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  ami                    = var.amis[var.region]
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  tags                   = var.tags
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}

output "ip" {
  value = aws_eip.ip.public_ip
}

output "ami" {
  value = aws_instance.example.ami
}

output "instance_type" {
  value = aws_instance.example.instance_type
}

output "vpc_security_group_ids" {
  value = aws_instance.example.vpc_security_group_ids
}

output "subnet_id" {
  value = aws_instance.example.subnet_id
}

output "tags" {
  value = aws_instance.example.tags
}

output "region" {
  value = var.region
}

output "profile" {
  value = var.profile
}

output "password" {
  value = var.password
}
