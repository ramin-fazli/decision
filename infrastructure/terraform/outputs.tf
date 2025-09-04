# Main Terraform Outputs

# Networking outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

# Kubernetes cluster outputs
output "cluster_endpoint" {
  description = "Endpoint for the Kubernetes cluster"
  value       = module.compute.cluster_endpoint
  sensitive   = true
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = module.compute.cluster_name
}

output "cluster_security_group_id" {
  description = "Security group ID for the cluster"
  value       = module.compute.cluster_security_group_id
}

output "cluster_arn" {
  description = "ARN of the Kubernetes cluster"
  value       = module.compute.cluster_arn
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.compute.cluster_ca_certificate
  sensitive   = true
}

output "cluster_token" {
  description = "Token for accessing the Kubernetes cluster"
  value       = module.compute.cluster_token
  sensitive   = true
}

# Database outputs
output "database_endpoint" {
  description = "PostgreSQL database endpoint"
  value       = module.database.database_endpoint
  sensitive   = true
}

output "database_port" {
  description = "PostgreSQL database port"
  value       = module.database.database_port
}

output "redis_endpoint" {
  description = "Redis endpoint"
  value       = module.database.redis_endpoint
  sensitive   = true
}

output "redis_port" {
  description = "Redis port"
  value       = module.database.redis_port
}

# Storage outputs
output "storage_bucket_name" {
  description = "Name of the storage bucket"
  value       = module.storage.storage_bucket_name
}

output "storage_bucket_arn" {
  description = "ARN of the storage bucket"
  value       = module.storage.storage_bucket_arn
}

output "storage_encryption_key_id" {
  description = "ID of the storage encryption key"
  value       = module.storage.storage_encryption_key_id
  sensitive   = true
}

# Application outputs
output "application_url" {
  description = "URL of the deployed application"
  value       = "https://${var.domain_name}"
}

output "monitoring_url" {
  description = "URL of the monitoring dashboard"
  value       = var.enable_monitoring ? "https://monitoring.${var.domain_name}" : null
}

# Environment information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "cloud_provider" {
  description = "Cloud provider used"
  value       = var.cloud_provider
}

output "region" {
  description = "Region where resources are deployed"
  value = var.cloud_provider == "aws" ? var.aws_region : var.cloud_provider == "gcp" ? var.gcp_region : var.azure_location
}

# Security outputs
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.compute.cluster_oidc_issuer_url
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID"
  value       = module.compute.cluster_primary_security_group_id
}

# Backup information
output "backup_enabled" {
  description = "Whether backups are enabled"
  value       = var.enable_backup
}

output "backup_retention_days" {
  description = "Backup retention period in days"
  value       = var.backup_retention_period
}

# Monitoring information
output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = var.enable_monitoring
}

# Tags
output "common_tags" {
  description = "Common tags applied to resources"
  value       = var.common_tags
}
