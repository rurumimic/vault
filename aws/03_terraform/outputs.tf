output "ids" {
  description = "List of IDs of instances"
  value       = module.ec2.id
}

output "private_ip" {
  description = "List of private ip assigned to the instances"
  value       = module.ec2.private_ip
}
