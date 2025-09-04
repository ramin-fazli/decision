# Storage Module Variables
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "decision"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (aws, gcp, azure)"
  type        = string
  validation {
    condition     = contains(["aws", "gcp", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, gcp, azure."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# AWS specific variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  type        = string
  default     = ""
}

variable "enable_backup" {
  description = "Enable backup bucket and replication"
  type        = bool
  default     = true
}

# GCP specific variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-west1"
}

# Azure specific variables
variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = ""
}

variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "West US 2"
}

# Storage configuration
variable "storage_size_threshold_gb" {
  description = "Storage size threshold in GB for alerting"
  type        = number
  default     = 100
}

variable "object_count_threshold" {
  description = "Object count threshold for alerting"
  type        = number
  default     = 1000000
}

variable "lifecycle_rules" {
  description = "Storage lifecycle rules configuration"
  type = object({
    standard_to_ia_days      = number
    ia_to_glacier_days       = number
    glacier_to_archive_days  = number
    log_retention_days       = number
    version_retention_days   = number
  })
  default = {
    standard_to_ia_days     = 30
    ia_to_glacier_days      = 90
    glacier_to_archive_days = 365
    log_retention_days      = 90
    version_retention_days  = 90
  }
}

variable "encryption_at_rest" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable storage versioning"
  type        = bool
  default     = true
}

variable "enable_public_access_block" {
  description = "Enable public access block (AWS)"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable storage monitoring and alerting"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 2555 # 7 years
}

variable "cross_region_replication" {
  description = "Enable cross-region replication for backup"
  type        = bool
  default     = false
}

variable "backup_region" {
  description = "Backup region for cross-region replication"
  type        = string
  default     = ""
}

# ML specific storage configuration
variable "ml_model_retention_days" {
  description = "ML model retention period in days"
  type        = number
  default     = 365
}

variable "ml_data_lifecycle_enabled" {
  description = "Enable ML data lifecycle management"
  type        = bool
  default     = true
}

# Compliance and governance
variable "compliance_mode" {
  description = "Enable compliance mode with additional security controls"
  type        = bool
  default     = false
}

variable "data_classification" {
  description = "Data classification level (public, internal, confidential, restricted)"
  type        = string
  default     = "internal"
  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "enable_access_logging" {
  description = "Enable access logging for storage bucket"
  type        = bool
  default     = true
}

variable "log_bucket_name" {
  description = "Name of the bucket for access logs"
  type        = string
  default     = ""
}

# Performance configuration
variable "storage_class" {
  description = "Default storage class"
  type        = string
  default     = "STANDARD"
}

variable "transfer_acceleration" {
  description = "Enable transfer acceleration (AWS)"
  type        = bool
  default     = false
}

variable "multipart_upload_threshold" {
  description = "Threshold for multipart uploads in bytes"
  type        = number
  default     = 104857600 # 100MB
}
