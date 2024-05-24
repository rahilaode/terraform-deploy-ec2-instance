# Define required providers, in this case, AWS. 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Constraint on the AWS provider version
    }
  }
}

# Configure the AWS provider with the specified region, access key, and secret key.
provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

# Create an SSH key pair resource in AWS using a provided public key file.
resource "aws_key_pair" "deployer" {
  key_name   = var.KEY-NAME
  public_key = file("./demo-devops-class.pub")
}

# Create a security group to control inbound traffic to instances.
resource "aws_security_group" "network-security-group" {
  name        = var.SECURITY-GROUP-NAME
  description = "Allow TLS inbound SSH traffic and all outbound traffic"

  ingress {
    description = "SSH"
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

  # Add tags for better identification.
  tags = {
    Name = "SG-demo-devops-class"
  }
}

# Create an AWS instance for production environment.
resource "aws_instance" "demo-devops-prd" {
  ami                    = "ami-00c31062c5966e820"  # Ubuntu AMI
  instance_type          = "t3.micro"  # Instance type
  key_name               = aws_key_pair.deployer.key_name  # SSH key pair for authentication
  vpc_security_group_ids = [aws_security_group.network-security-group.id]  # Attach the security group

  # Add tags for better identification.
  tags = {
    Name = "demo-devops-prd"
  }
}

# Create an AWS instance for staging environment.
resource "aws_instance" "demo-devops-stg" {
  ami                    = "ami-00c31062c5966e820"  # Ubuntu AMI
  instance_type          = "t3.micro"  # Instance type
  key_name               = aws_key_pair.deployer.key_name  # SSH key pair for authentication
  vpc_security_group_ids = [aws_security_group.network-security-group.id]  # Attach the security group

  # Add tags for better identification.
  tags = {
    Name = "demo-devops-stg"
  }
}
