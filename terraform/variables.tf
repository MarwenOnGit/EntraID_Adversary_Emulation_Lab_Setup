variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-west-3"
}

variable "ami_id" {
  description = "Optional: AMI ID to use (leave empty to use latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Optional: SSH key pair name to attach to the instance"
  type        = string
  default     = ""
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key on the control machine that will be used by Ansible"
  type        = string
  default     = "terraform/keys/id_rsa"
}

variable "ssh_user" {
  description = "Default SSH user for the instance (ubuntu for Ubuntu AMIs, ec2-user for Amazon Linux)"
  type        = string
  default     = "ubuntu"
}

variable "eip" {
  description = "Existing Elastic IP address to associate with the instance"
  type        = string
}
