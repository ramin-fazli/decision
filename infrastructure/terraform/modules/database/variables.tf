# Database Module Variables

variable "cloud_provider" {
  description = "Cloud provider to use (aws, gcp, azure)"
  type        = string

  validation {
    condition     = contains(["aws", "gcp", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, gcp, azure."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID where the database will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the database"
  type        = list(string)
}

variable "resource_group_name" {
  description = "Name of the resource group (Azure only)"
  type        = string
  default     = null
}

# PostgreSQL Configuration
variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "postgres_instance_class" {
  description = "PostgreSQL instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_allocated_storage" {
  description = "PostgreSQL allocated storage in GB"
  type        = number
  default     = 20
}

variable "postgres_max_allocated_storage" {
  description = "PostgreSQL maximum allocated storage in GB"
  type        = number
  default     = 100
}

variable "postgres_database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "decision"
}

variable "postgres_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "postgres_backup_retention_period" {
  description = "PostgreSQL backup retention period in days"
  type        = number
  default     = 7
}

variable "postgres_backup_window" {
  description = "PostgreSQL backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "postgres_maintenance_window" {
  description = "PostgreSQL maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "postgres_multi_az" {
  description = "Enable PostgreSQL Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "postgres_publicly_accessible" {
  description = "Make PostgreSQL publicly accessible"
  type        = bool
  default     = false
}

variable "postgres_storage_encrypted" {
  description = "Enable PostgreSQL storage encryption"
  type        = bool
  default     = true
}

variable "postgres_deletion_protection" {
  description = "Enable PostgreSQL deletion protection"
  type        = bool
  default     = true
}

variable "postgres_skip_final_snapshot" {
  description = "Skip PostgreSQL final snapshot"
  type        = bool
  default     = false
}

variable "postgres_performance_insights_enabled" {
  description = "Enable PostgreSQL Performance Insights"
  type        = bool
  default     = true
}

variable "postgres_performance_insights_retention_period" {
  description = "PostgreSQL Performance Insights retention period in days"
  type        = number
  default     = 7
}

variable "postgres_monitoring_interval" {
  description = "PostgreSQL monitoring interval in seconds"
  type        = number
  default     = 60
}

variable "postgres_enable_logging" {
  description = "Enable PostgreSQL logging"
  type        = bool
  default     = true
}

# Redis Configuration
variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "7.0"
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_nodes" {
  description = "Number of Redis cache nodes"
  type        = number
  default     = 1
}

variable "redis_port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "redis_auth_token" {
  description = "Redis auth token"
  type        = string
  sensitive   = true
  default     = null
}

variable "redis_at_rest_encryption_enabled" {
  description = "Enable Redis encryption at rest"
  type        = bool
  default     = true
}

variable "redis_transit_encryption_enabled" {
  description = "Enable Redis encryption in transit"
  type        = bool
  default     = true
}

variable "redis_automatic_failover_enabled" {
  description = "Enable Redis automatic failover"
  type        = bool
  default     = true
}

variable "redis_multi_az_enabled" {
  description = "Enable Redis Multi-AZ"
  type        = bool
  default     = false
}

variable "redis_snapshot_retention_limit" {
  description = "Redis snapshot retention limit in days"
  type        = number
  default     = 5
}

variable "redis_snapshot_window" {
  description = "Redis snapshot window"
  type        = string
  default     = "03:00-05:00"
}

variable "redis_maintenance_window" {
  description = "Redis maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "redis_log_delivery_configuration" {
  description = "Redis log delivery configuration"
  type = map(object({
    destination      = string
    destination_type = string
    log_format       = string
    log_type         = string
  }))
  default = {}
}

# High Availability Configuration
variable "enable_read_replicas" {
  description = "Enable read replicas for PostgreSQL"
  type        = bool
  default     = false
}

variable "read_replica_count" {
  description = "Number of read replicas"
  type        = number
  default     = 1
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup"
  type        = bool
  default     = false
}

variable "backup_cross_region_destination" {
  description = "Cross-region backup destination"
  type        = string
  default     = null
}

# Security Configuration
variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the databases"
  type        = list(string)
  default     = []
}

variable "enable_ssl_enforcement" {
  description = "Enable SSL enforcement for PostgreSQL"
  type        = bool
  default     = true
}

variable "ssl_minimal_tls_version" {
  description = "Minimal TLS version for SSL connections"
  type        = string
  default     = "TLSv1.2"
}

# Monitoring and Alerting
variable "enable_monitoring" {
  description = "Enable database monitoring"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}

variable "enable_cpu_utilization_alarm" {
  description = "Enable CPU utilization alarm"
  type        = bool
  default     = true
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold for alarm"
  type        = number
  default     = 80
}

variable "enable_connection_count_alarm" {
  description = "Enable database connection count alarm"
  type        = bool
  default     = true
}

variable "connection_count_threshold" {
  description = "Database connection count threshold for alarm"
  type        = number
  default     = 80
}

variable "enable_free_storage_space_alarm" {
  description = "Enable free storage space alarm"
  type        = bool
  default     = true
}

variable "free_storage_space_threshold" {
  description = "Free storage space threshold in bytes"
  type        = number
  default     = 2000000000 # 2GB
}

# Backup and Recovery
variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "backup_schedule" {
  description = "Backup schedule in cron format"
  type        = string
  default     = "0 2 * * *" # Daily at 2 AM
}

variable "enable_automated_backup" {
  description = "Enable automated backup"
  type        = bool
  default     = true
}

# Cost Optimization
variable "enable_auto_scaling" {
  description = "Enable auto scaling for databases"
  type        = bool
  default     = false
}

variable "auto_scaling_target_cpu" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}

variable "auto_scaling_target_connections" {
  description = "Target connection utilization for auto scaling"
  type        = number
  default     = 70
}

variable "enable_serverless" {
  description = "Enable serverless configuration (where available)"
  type        = bool
  default     = false
}

variable "serverless_min_capacity" {
  description = "Minimum serverless capacity units"
  type        = number
  default     = 2
}

variable "serverless_max_capacity" {
  description = "Maximum serverless capacity units"
  type        = number
  default     = 16
}

variable "serverless_auto_pause" {
  description = "Enable auto-pause for serverless"
  type        = bool
  default     = false
}

variable "serverless_seconds_until_auto_pause" {
  description = "Seconds until auto-pause"
  type        = number
  default     = 300
}
