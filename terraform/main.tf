data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners       = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
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
  ami                    = length(var.ami_id) > 0 ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.redteam.id]

  tags = {
    Name      = "redteam-${terraform.workspace}"
    CreatedBy = "terraform"
  }
}
