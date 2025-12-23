output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.redteam.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.redteam.public_ip
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.redteam.private_ip
}

output "ssh_user" {
  description = "SSH user for the instance"
  value       = var.ssh_user
}

output "ssh_key_path" {
  description = "Path on the control machine to the SSH private key used to connect to the instance"
  value       = var.ssh_private_key_path
}

output "ssh_command" {
  description = "Suggested SSH command to connect to the instance"
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${aws_instance.redteam.public_ip}"
}

output "ansible_inventory" {
  description = "One-line Ansible inventory entry (copy-paste)"
  value       = "redteam-01 ansible_host=${aws_instance.redteam.public_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_private_key_path}"
}
