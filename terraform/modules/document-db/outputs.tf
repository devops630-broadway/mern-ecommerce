output "master_username" {
  value       = join("", aws_docdb_cluster.default[*].master_username)
  description = "Username for the master DB user"
}

output "master_password" {
  value       = compact(aws_docdb_cluster.default[*].master_password)
  description = "Password for the master DB user"
  sensitive   = true
}

output "cluster_name" {
  value       = join("", aws_docdb_cluster.default[*].cluster_identifier)
  description = "Cluster Identifier"
}

output "arn" {
  value       = join("", aws_docdb_cluster.default[*].arn)
  description = "Amazon Resource Name (ARN) of the cluster"
}

output "endpoint" {
  value       = join("", aws_docdb_cluster.default[*].endpoint)
  description = "Endpoint of the DocumentDB cluster"
}

output "reader_endpoint" {
  value       = join("", aws_docdb_cluster.default[*].reader_endpoint)
  description = "A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas"
}

