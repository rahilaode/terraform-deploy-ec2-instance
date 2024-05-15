# How To Deploy Multiple AWS EC2 INSTANCES Using Instances - Example
This is a example of how to deploy multiple ec2 instances using terraform.

## Requirements
- Make sure you have **AWS Acoount**. *If you don't have AWS Account, you must create one. Open https://aws.amazon.com/ then follow the intructions to create aws account*.
- Create IAM user and **create `Access Key` and `Secret Access Key`**. *Open https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html to read the docs. Copy your `Access Key` and `Secret Access Key`.*
- Install terraform. *In this case i use WSL. Read this artical to install terraform in WSL : https://medium.com/@chranga007/how-to-configure-terraform-in-wsl-e9f0c669cda5.*
- **Create an SSH key pair** on local system serves as a secure and convenient method for authenticating yourself when connecting to remote servers, such as instances on AWS. Use this command `ssh-keygen -t rsa -b 2048 -f <key name>`

## Create Terraform Configurations
### main.tf
- `main.tf` is my main terraform script / configurations.
- See the `main.tf` for the configurations.
- Let's break it down :
    - **Provider Configuration**.
    The script begins by declaring the required provider, which in this case is AWS. It specifies the source and version of the AWS provider that Terraform should use.
        ```
        # Define required providers, in this case, AWS. 
        terraform {
            required_providers {
                aws = {
                    source  = "hashicorp/aws"
                    version = "~> 5.0"  # Constraint on the AWS provider version
                }
            }
        }
        ```

    - **AWS Provider Configuration**,
    Next, the script configures the AWS provider with the necessary authentication details like region, access key, and secret key. These values are provided through variables, which allows for flexibility and security in managing AWS credentials.
        ```
        # Configure the AWS provider with the specified region, access key, and secret key.
        provider "aws" {
            region     = var.AWS_REGION
            access_key = var.AWS_ACCESS_KEY
            secret_key = var.AWS_SECRET_KEY
        }
        ```

    - **SSH Key Pair Creation**.
    The script then proceeds to create an SSH key pair named "deployer" on AWS. This key pair is crucial for securely accessing the created instances later on. It utilizes a provided public key file (.pub) to generate the key pair.
        ```
        # Create an SSH key pair resource in AWS using a provided public key file.
        resource "aws_key_pair" "deployer" {
            key_name   = var.KEY-NAME
            public_key = file("./demo-devops-class.pub")
        }
        ```

    - **Security Group Creation**.
    Following that, the script defines a security group named "network-security-group". Security groups act as virtual firewalls, controlling inbound and outbound traffic to AWS instances. In this case, it allows inbound SSH traffic (port 22) from any IP address (0.0.0.0/0). However, the comment suggests that it's not the best practice, and a more restricted IP range would be preferable for security reasons.
        ```
        # Create a security group to control inbound traffic to instances.
        resource "aws_security_group" "network-security-group" {
            name        = var.SECURITY-GROUP-NAME
            description = "Allow TLS inbound traffic"

            # Allow SSH inbound traffic from any IP address.
            ingress {
                description = "SSH"
                from_port   = 22
                to_port     = 22
                protocol    = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
            }

            # Add tags for better identification.
            tags = {
                Name = "SG-demo-devops-class"
            }
        }
        ```

    - **AWS Instance Creation (Production and Staging)**.
    The script then creates two AWS instances, one for the production environment (demo-devops-prd) and one for the staging environment (demo-devops-stg). Both instances use the same Ubuntu AMI (ami-00c31062c5966e820) and instance type (t3.micro). They are associated with the previously created security group to control their network access. Each instance is tagged for identification purposes.
        ```
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
        ```

### vars.tf
- In Terraform, `vars.tf` is a conventionally named file used to define input variables. These variables allow users to parameterize their Terraform configurations, making them more flexible, reusable, and easier to manage.
- Create `vars.tf`.
    ```
    # vars.tf

    variable "AWS_REGION" {
        default = "..." #The AWS region where resources will be provisioned.
    }

    variable "AWS_ACCESS_KEY" {
        default = "..." #The access key for AWS authentication.
    }

    variable "AWS_SECRET_KEY" {
        default = "..." #The secret key for AWS authentication. 
    }

    variable "KEY-NAME" {
        default = "..." #The name of the SSH key pair to create. 
    }

    variable "SECURITY-GROUP-NAME" {
        default = "..." #The name of the security group to create.
    }
    ```
- In `main.tf`, we can read those variables with format `var.VARIABLE_NAME`. Example:
    ```
    provider "aws" {
        region     = var.AWS_REGION
        access_key = var.AWS_ACCESS_KEY
        secret_key = var.AWS_SECRET_KEY
    }
    ```

## Terraform Commands
After terraform configurations done, run the following command.
- `terraform init`. This command will initializes a working directory and downloads the necessary provider plugins and modules and setting up the backend for storing your infrastructure's state.
- `terraform fmt`. This command will reformat your configuration in the standard style.
- `terraform validate`. This command will check whether the configuration is valid.
- `terraform plan`. This command will show changes required by the current configuration.
- `terraform appy`. This command will create or update infrastructure.