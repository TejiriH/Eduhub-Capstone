# Inside modules/primary_networking/outputs.tf (and same for secondary)
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "eks_subnet_ids" {
  description = "List of private EKS subnet IDs"
  value       = aws_subnet.eks_private[*].id
}

# (you probably also want these for completeness)
output "storage_subnet_ids" {
  value = aws_subnet.storage_private[*].id
}