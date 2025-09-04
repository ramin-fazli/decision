# Storage Module Outputs
output "storage_bucket_name" {
  description = "Name of the primary storage bucket"
  value = var.cloud_provider == "aws" ? (
    length(aws_s3_bucket.decision_storage) > 0 ? aws_s3_bucket.decision_storage[0].bucket : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_storage_bucket.decision_storage) > 0 ? google_storage_bucket.decision_storage[0].name : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_storage_account.decision_storage) > 0 ? azurerm_storage_account.decision_storage[0].name : null
  ) : null
}

output "storage_bucket_arn" {
  description = "ARN of the storage bucket (AWS only)"
  value       = var.cloud_provider == "aws" && length(aws_s3_bucket.decision_storage) > 0 ? aws_s3_bucket.decision_storage[0].arn : null
}

output "storage_encryption_key_id" {
  description = "ID of the storage encryption key"
  value = var.cloud_provider == "aws" ? (
    length(aws_kms_key.storage_key) > 0 ? aws_kms_key.storage_key[0].id : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_kms_crypto_key.storage_key) > 0 ? google_kms_crypto_key.storage_key[0].id : null
  ) : null
}

output "storage_encryption_key_arn" {
  description = "ARN of the storage encryption key (AWS only)"
  value       = var.cloud_provider == "aws" && length(aws_kms_key.storage_key) > 0 ? aws_kms_key.storage_key[0].arn : null
}

output "backup_bucket_name" {
  description = "Name of the backup bucket"
  value       = var.cloud_provider == "aws" && var.enable_backup && length(aws_s3_bucket.decision_backup) > 0 ? aws_s3_bucket.decision_backup[0].bucket : null
}

output "backup_bucket_arn" {
  description = "ARN of the backup bucket (AWS only)"
  value       = var.cloud_provider == "aws" && var.enable_backup && length(aws_s3_bucket.decision_backup) > 0 ? aws_s3_bucket.decision_backup[0].arn : null
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint (Azure only)"
  value       = var.cloud_provider == "azure" && length(azurerm_storage_account.decision_storage) > 0 ? azurerm_storage_account.decision_storage[0].primary_blob_endpoint : null
}

output "storage_container_name" {
  description = "Name of the storage container (Azure only)"
  value       = var.cloud_provider == "azure" && length(azurerm_storage_container.decision_storage_container) > 0 ? azurerm_storage_container.decision_storage_container[0].name : null
}

output "gcs_bucket_url" {
  description = "URL of the GCS bucket (GCP only)"
  value       = var.cloud_provider == "gcp" && length(google_storage_bucket.decision_storage) > 0 ? google_storage_bucket.decision_storage[0].url : null
}

output "storage_monitoring_enabled" {
  description = "Whether storage monitoring is enabled"
  value       = var.enable_monitoring
}

output "lambda_function_arn" {
  description = "ARN of the storage processing Lambda function (AWS only)"
  value       = var.cloud_provider == "aws" && length(aws_lambda_function.storage_processor) > 0 ? aws_lambda_function.storage_processor[0].arn : null
}

output "storage_lifecycle_configured" {
  description = "Whether storage lifecycle is configured"
  value       = true
}

output "encryption_at_rest_enabled" {
  description = "Whether encryption at rest is enabled"
  value       = var.encryption_at_rest
}

output "versioning_enabled" {
  description = "Whether versioning is enabled"
  value       = var.enable_versioning
}

output "cross_region_replication_enabled" {
  description = "Whether cross-region replication is enabled"
  value       = var.cross_region_replication
}

output "storage_class" {
  description = "Default storage class"
  value       = var.storage_class
}

output "data_classification" {
  description = "Data classification level"
  value       = var.data_classification
  sensitive   = true
}

output "storage_region" {
  description = "Storage region"
  value       = var.cloud_provider == "aws" ? var.aws_region : var.cloud_provider == "gcp" ? var.gcp_region : var.azure_location
}

output "compliance_mode_enabled" {
  description = "Whether compliance mode is enabled"
  value       = var.compliance_mode
}
