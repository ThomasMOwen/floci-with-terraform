output "cluster_id" {
  description = "Cluster Id"
  value       = aws_eks_cluster.temp_environment.id
}