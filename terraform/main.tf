data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners       = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "redteam" {
  ami           = length(var.ami_id) > 0 ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  tags = {
    Name      = "redteam-${terraform.workspace}"
    CreatedBy = "terraform"
  }
}
