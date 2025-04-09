output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.my_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.my_cluster.endpoint
}

output "redis_endpoint" {
  description = "Endpoint of the Redis instance"
  value       = aws_elasticache_cluster.redis_cart.configuration_endpoint
}
