# Terraform AWS User Setup Guide

## Required IAM Permissions for EC2 Instance Spawning

For Terraform to spawn EC2 instances, the user needs the following permissions:

### Core EC2 Permissions
- **ec2:RunInstances** - Launch new instances
- **ec2:TerminateInstances** - Terminate instances
- **ec2:DescribeInstances** - Get instance information
- **ec2:DescribeInstanceTypes** - Get instance type details
- **ec2:DescribeInstanceStatus** - Check instance status

### Networking Permissions (often required)
- **ec2:DescribeSecurityGroups** - View security groups
- **ec2:DescribeNetworkInterfaces** - View network interfaces
- **ec2:DescribeSubnets** - View available subnets
- **ec2:DescribeVpcs** - View VPCs

### Volume/Storage Permissions
- **ec2:DescribeVolumes** - View volumes
- **ec2:CreateVolume** - Create volumes (if needed)
- **ec2:DeleteVolume** - Delete volumes (cleanup)

### Tags (for resource management)
- **ec2:CreateTags** - Tag resources
- **ec2:DescribeTags** - View tags

### AMI Permissions
- **ec2:DescribeImages** - Get AMI information

### Optional but Recommended
- **ec2:StartInstances** - Start stopped instances
- **ec2:StopInstances** - Stop running instances
- **ec2:RebootInstances** - Reboot instances

## Step 1: Create IAM Policy

Create a file named `terraform-ec2-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2RunInstances",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:RebootInstances"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:network-interface/*"
      ]
    },
    {
      "Sid": "EC2Describe",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DescribeVolumes",
        "ec2:DescribeImages",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    },
    {
      "Sid": "EC2TagResources",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags",
        "ec2:DeleteTags"
      ],
      "Resource": "arn:aws:ec2:*:*:*"
    },
    {
      "Sid": "EC2VolumeManagement",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:AttachVolume",
        "ec2:DetachVolume"
      ],
      "Resource": "arn:aws:ec2:*:*:*"
    }
  ]
}
```

## Step 2: AWS CLI Commands to Create User

```bash
# Set variables
TERRAFORM_USER="terraform"
POLICY_NAME="TerraformEC2Policy"

# Create IAM user
aws iam create-user --user-name $TERRAFORM_USER

# Create policy document
aws iam put-user-policy --user-name $TERRAFORM_USER \
  --policy-name $POLICY_NAME \
  --policy-document file://terraform-ec2-policy.json

# Create access keys for the user
aws iam create-access-key --user-name $TERRAFORM_USER
```

**⚠️ IMPORTANT:** Save the Access Key ID and Secret Access Key from the output. You won't be able to see the secret again.

## Step 3: Configure Terraform

Save the credentials and configure your Terraform environment:

```bash
# Option 1: AWS CLI configuration
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format: json

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your_access_key_id"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 3: Terraform variables (create terraform.tfvars)
aws_access_key = "your_access_key_id"
aws_secret_key = "your_secret_access_key"
aws_region     = "us-east-1"
```

## Step 4: Verify User Permissions

```bash
# Test EC2 access
aws ec2 describe-instances --profile terraform

# Test ability to create instance (dry-run)
aws ec2 run-instances --image-id ami-0c55b159cbfafe1f0 --instance-type t2.micro --dry-run
```

## Minimal Policy (If you want the absolute minimum)

If you only want the user to spawn instances without manage lifecycle:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:CreateTags",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    }
  ]
}
```

## Security Best Practices

1. **Rotate Access Keys Regularly**: Every 90 days
2. **Use MFA**: Enable multi-factor authentication for the user
3. **Monitor Usage**: Set up CloudTrail logging
4. **Limit Scope**: Consider restricting by region:
   ```json
   "Resource": "arn:aws:ec2:us-east-1:*:*"
   ```
5. **Use Terraform Backend**: Store state remotely with encryption
6. **Avoid Root Account**: Never use root credentials with Terraform
7. **Regular Audits**: Review attached policies monthly

## Cleanup Commands

```bash
# Deactivate access keys
aws iam update-access-key --user-name terraform --access-key-id AKIAIOSFODNN7EXAMPLE --status Inactive

# Delete user (and associated policies)
aws iam delete-access-key --user-name terraform --access-key-id AKIAIOSFODNN7EXAMPLE
aws iam delete-user-policy --user-name terraform --policy-name TerraformEC2Policy
aws iam delete-user --user-name terraform
```

## Terraform Example

Once set up, your Terraform can use this user:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "red_team_instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  
  tags = {
    Name = "RedTeamServer"
  }
}
```
