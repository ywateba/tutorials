output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.swarm_lb.dns_name
}

# output "manager_instance_ids" {
#   description = "The IDs of the manager instances"
#   value       = aws_instance.manager[*].id
# }

# output "worker_instance_ids" {
#   description = "The IDs of the worker instances"
#   value       = aws_instance.worker[*].id
# }

output "efs_file_system_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.efs.id
}
