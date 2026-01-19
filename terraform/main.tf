resource "tls_private_key" "redteam" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "redteam" {
  key_name   = "redteam-key-${terraform.workspace}"
  public_key = tls_private_key.redteam.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/keys/id_rsa"
  content         = tls_private_key.redteam.private_key_pem
  file_permission = "0600"
}

resource "local_file" "public_key" {
  filename = "${path.module}/keys/id_rsa.pub"
  content  = tls_private_key.redteam.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "redteam" {
  name_prefix = "redteam-"
  description = "Red team instance security"

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

resource "aws_instance" "redteam" {
  ami                    = length(var.ami_id) > 0 ? var.ami_id : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.redteam.id]
  key_name               = aws_key_pair.redteam.key_name
  associate_public_ip_address = false

  tags = {
    Name      = "redteam-${terraform.workspace}"
    CreatedBy = "terraform"
  }

  depends_on = [local_sensitive_file.private_key]
}

data "aws_eip" "existing" {
  filter {
    name   = "public-ip"
    values = [var.eip]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.redteam.id
  allocation_id = data.aws_eip.existing.id
}
