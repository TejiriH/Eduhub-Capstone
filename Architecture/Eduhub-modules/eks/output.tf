# Outputs (add to outputs.tf)
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_node_group_arn" {
  value = aws_eks_node_group.main.arn
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster.id
}

output "nodes_security_group_id" {
  value = aws_security_group.eks_nodes.id
}