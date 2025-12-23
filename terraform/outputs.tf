output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.redteam.id
}

output "public_ip" {
  description = "Public IP of the instance (if assigned)"
  value       = aws_instance.redteam.public_ip
}
