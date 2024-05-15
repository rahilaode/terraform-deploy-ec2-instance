terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

# Creating key-pair on AWS using SSH-public key
resource "aws_key_pair" "deployer" {
  key_name   = var.KEY-NAME
  public_key = file("./demo-devops-class.pub")
}

# Creating a security group to restrict/allow inbound connectivity
resource "aws_security_group" "network-security-group" {
  name        = var.SECURITY-GROUP-NAME
  description = "Allow TLS inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Not recommended to add "0.0.0.0/0" instead we need to be more specific with the IP ranges to allow connectivity from.
  tags = {
    Name = "SG-demo-devops-class"
  }
}

# Create ubuntu vm for productions
resource "aws_instance" "demo-devops-prd" {
  ami                    = "ami-00c31062c5966e820"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network-security-group.id]

  tags = {
    Name = "demo-devops-prd"
  }
}

# Create ubuntu vm for staging
resource "aws_instance" "demo-devops-stg" {
  ami                    = "ami-00c31062c5966e820"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network-security-group.id]

  tags = {
    Name = "demo-devops-stg"
  }
}
