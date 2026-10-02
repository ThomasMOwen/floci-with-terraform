output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.cluster_vpc.id
}