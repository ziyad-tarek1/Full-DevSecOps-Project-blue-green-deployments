output "ssh_to_ec2" {
  description = "Command to SSH into the EC2 instance."
  value       = "ssh -i ${local_file.demo1_private_key.filename} ec2-user@${aws_instance.demo1_ec2.public_ip}"
}

output "demo1_ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.demo1_ec2.public_ip
}

output "demo1_ec2_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.demo1_ec2.id
}
