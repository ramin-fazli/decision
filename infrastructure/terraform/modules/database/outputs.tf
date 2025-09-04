# Database Module Outputs

# PostgreSQL Database Outputs
output "database_endpoint" {
  description = "PostgreSQL database endpoint"
  value = var.cloud_provider == "aws" ? (
    length(aws_db_instance.postgres) > 0 ? aws_db_instance.postgres[0].endpoint : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_sql_database_instance.postgres) > 0 ? google_sql_database_instance.postgres[0].connection_name : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_postgresql_flexible_server.main) > 0 ? azurerm_postgresql_flexible_server.main[0].fqdn : null
  ) : null
  sensitive = true
}

output "database_port" {
  description = "PostgreSQL database port"
  value       = var.postgres_port
}

output "database_name" {
  description = "PostgreSQL database name"
  value       = var.postgres_database_name
}

output "database_username" {
  description = "PostgreSQL database username"
  value       = var.postgres_username
  sensitive   = true
}

output "database_connection_string" {
  description = "PostgreSQL database connection string"
  value = var.cloud_provider == "aws" ? (
    length(aws_db_instance.postgres) > 0 ? "postgresql://${var.postgres_username}:${var.postgres_password}@${aws_db_instance.postgres[0].endpoint}:${var.postgres_port}/${var.postgres_database_name}" : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_sql_database_instance.postgres) > 0 ? "postgresql://${var.postgres_username}:${var.postgres_password}@${google_sql_database_instance.postgres[0].private_ip_address}:${var.postgres_port}/${var.postgres_database_name}" : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_postgresql_flexible_server.main) > 0 ? "postgresql://${var.postgres_username}:${var.postgres_password}@${azurerm_postgresql_flexible_server.main[0].fqdn}:${var.postgres_port}/${var.postgres_database_name}" : null
  ) : null
  sensitive = true
}

output "database_id" {
  description = "PostgreSQL database instance ID"
  value = var.cloud_provider == "aws" ? (
    length(aws_db_instance.postgres) > 0 ? aws_db_instance.postgres[0].id : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_sql_database_instance.postgres) > 0 ? google_sql_database_instance.postgres[0].id : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_postgresql_flexible_server.main) > 0 ? azurerm_postgresql_flexible_server.main[0].id : null
  ) : null
}

output "database_arn" {
  description = "PostgreSQL database ARN (AWS only)"
  value = var.cloud_provider == "aws" ? (
    length(aws_db_instance.postgres) > 0 ? aws_db_instance.postgres[0].arn : null
  ) : null
}

output "database_availability_zone" {
  description = "PostgreSQL database availability zone"
  value = var.cloud_provider == "aws" ? (
    length(aws_db_instance.postgres) > 0 ? aws_db_instance.postgres[0].availability_zone : null
  ) : null
}

output "database_backup_retention_period" {
  description = "PostgreSQL backup retention period"
  value       = local.backup_retention
}

output "database_backup_window" {
  description = "PostgreSQL backup window"
  value       = var.postgres_backup_window
}

output "database_maintenance_window" {
  description = "PostgreSQL maintenance window"
  value       = var.postgres_maintenance_window
}

output "database_engine_version" {
  description = "PostgreSQL engine version"
  value       = var.postgres_version
}

output "database_multi_az" {
  description = "PostgreSQL Multi-AZ deployment status"
  value       = var.postgres_multi_az
}

output "database_storage_encrypted" {
  description = "PostgreSQL storage encryption status"
  value       = var.postgres_storage_encrypted
}

output "database_performance_insights_enabled" {
  description = "PostgreSQL Performance Insights status"
  value       = var.postgres_performance_insights_enabled
}

# Redis Cache Outputs
output "redis_endpoint" {
  description = "Redis cache endpoint"
  value = var.cloud_provider == "aws" ? (
    length(aws_elasticache_replication_group.redis) > 0 ? aws_elasticache_replication_group.redis[0].primary_endpoint_address : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_redis_instance.main) > 0 ? google_redis_instance.main[0].host : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].hostname : null
  ) : null
  sensitive = true
}

output "redis_port" {
  description = "Redis cache port"
  value       = var.redis_port
}

output "redis_auth_token" {
  description = "Redis auth token"
  value = var.cloud_provider == "aws" ? (
    var.redis_transit_encryption_enabled ? (
      var.redis_auth_token != null ? var.redis_auth_token : (
        length(random_password.redis_auth_token) > 0 ? random_password.redis_auth_token[0].result : null
      )
    ) : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].primary_access_key : null
  ) : null
  sensitive = true
}

output "redis_connection_string" {
  description = "Redis connection string"
  value = var.cloud_provider == "aws" ? (
    length(aws_elasticache_replication_group.redis) > 0 ? (
      var.redis_transit_encryption_enabled ?
      "rediss://${aws_elasticache_replication_group.redis[0].primary_endpoint_address}:${var.redis_port}" :
      "redis://${aws_elasticache_replication_group.redis[0].primary_endpoint_address}:${var.redis_port}"
    ) : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_redis_instance.main) > 0 ? "redis://${google_redis_instance.main[0].host}:${var.redis_port}" : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_redis_cache.main) > 0 ? "redis://${azurerm_redis_cache.main[0].hostname}:${var.redis_port}" : null
  ) : null
  sensitive = true
}

output "redis_id" {
  description = "Redis cache instance ID"
  value = var.cloud_provider == "aws" ? (
    length(aws_elasticache_replication_group.redis) > 0 ? aws_elasticache_replication_group.redis[0].id : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_redis_instance.main) > 0 ? google_redis_instance.main[0].id : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].id : null
  ) : null
}

output "redis_version" {
  description = "Redis version"
  value       = var.redis_version
}

output "redis_node_type" {
  description = "Redis node type"
  value       = local.redis_node_type
}

output "redis_num_cache_nodes" {
  description = "Number of Redis cache nodes"
  value       = var.redis_num_cache_nodes
}

output "redis_encryption_at_rest" {
  description = "Redis encryption at rest status"
  value       = var.redis_at_rest_encryption_enabled
}

output "redis_encryption_in_transit" {
  description = "Redis encryption in transit status"
  value       = var.redis_transit_encryption_enabled
}

output "redis_automatic_failover" {
  description = "Redis automatic failover status"
  value       = var.redis_automatic_failover_enabled
}

output "redis_multi_az" {
  description = "Redis Multi-AZ status"
  value       = var.redis_multi_az_enabled
}

# Security Group Outputs
output "postgres_security_group_id" {
  description = "PostgreSQL security group ID"
  value = var.cloud_provider == "aws" ? (
    length(aws_security_group.postgres) > 0 ? aws_security_group.postgres[0].id : null
  ) : null
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value = var.cloud_provider == "aws" ? (
    length(aws_security_group.redis) > 0 ? aws_security_group.redis[0].id : null
  ) : null
}

# Subnet Group Outputs
output "postgres_subnet_group_name" {
  description = "PostgreSQL subnet group name"
  value = var.cloud_provider == "aws" ? (
    length(aws_db_subnet_group.postgres) > 0 ? aws_db_subnet_group.postgres[0].name : null
  ) : null
}

output "redis_subnet_group_name" {
  description = "Redis subnet group name"
  value = var.cloud_provider == "aws" ? (
    length(aws_elasticache_subnet_group.redis) > 0 ? aws_elasticache_subnet_group.redis[0].name : null
  ) : null
}

# Parameter Group Outputs
output "postgres_parameter_group_name" {
  description = "PostgreSQL parameter group name"
  value = var.cloud_provider == "aws" ? (
    length(aws_db_parameter_group.postgres) > 0 ? aws_db_parameter_group.postgres[0].name : null
  ) : null
}

output "redis_parameter_group_name" {
  description = "Redis parameter group name"
  value = var.cloud_provider == "aws" ? (
    length(aws_elasticache_parameter_group.redis) > 0 ? aws_elasticache_parameter_group.redis[0].name : null
  ) : null
}

# Read Replica Outputs
output "postgres_read_replica_endpoints" {
  description = "PostgreSQL read replica endpoints"
  value       = var.cloud_provider == "aws" && var.enable_read_replicas ? aws_db_instance.postgres_read_replica[*].endpoint : []
  sensitive   = true
}

output "postgres_read_replica_ids" {
  description = "PostgreSQL read replica IDs"
  value       = var.cloud_provider == "aws" && var.enable_read_replicas ? aws_db_instance.postgres_read_replica[*].id : []
}

# Monitoring Outputs
output "monitoring_enabled" {
  description = "Database monitoring status"
  value       = var.enable_monitoring
}

output "sns_topic_arn" {
  description = "SNS topic ARN for database alerts"
  value = var.cloud_provider == "aws" && var.enable_monitoring ? (
    length(aws_sns_topic.database_alerts) > 0 ? aws_sns_topic.database_alerts[0].arn : null
  ) : null
}

output "cloudwatch_log_group_names" {
  description = "CloudWatch log group names"
  value       = var.cloud_provider == "aws" && var.postgres_enable_logging ? ["${local.database_name}-postgres"] : []
}

# KMS Key Outputs
output "postgres_kms_key_id" {
  description = "PostgreSQL KMS key ID"
  value = var.cloud_provider == "aws" && var.postgres_storage_encrypted ? (
    length(aws_kms_key.postgres) > 0 ? aws_kms_key.postgres[0].key_id : null
  ) : null
}

output "postgres_kms_key_arn" {
  description = "PostgreSQL KMS key ARN"
  value = var.cloud_provider == "aws" && var.postgres_storage_encrypted ? (
    length(aws_kms_key.postgres) > 0 ? aws_kms_key.postgres[0].arn : null
  ) : null
}

# Cost and Performance Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost information"
  value = {
    postgres_instance_class = local.postgres_instance_class
    postgres_storage_gb     = var.postgres_allocated_storage
    redis_node_type         = local.redis_node_type
    redis_num_nodes         = var.redis_num_cache_nodes
    environment             = var.environment
    multi_az                = var.postgres_multi_az
    backup_retention_days   = local.backup_retention
  }
}

# Database Configuration Summary
output "database_configuration" {
  description = "Database configuration summary"
  value = {
    postgres = {
      version               = var.postgres_version
      instance_class        = local.postgres_instance_class
      allocated_storage     = var.postgres_allocated_storage
      max_allocated_storage = var.postgres_max_allocated_storage
      multi_az              = var.postgres_multi_az
      backup_retention      = local.backup_retention
      deletion_protection   = local.deletion_protection
      storage_encrypted     = var.postgres_storage_encrypted
      performance_insights  = var.postgres_performance_insights_enabled
      monitoring_interval   = var.postgres_monitoring_interval
    }
    redis = {
      version                  = var.redis_version
      node_type                = local.redis_node_type
      num_cache_nodes          = var.redis_num_cache_nodes
      automatic_failover       = var.redis_automatic_failover_enabled
      multi_az                 = var.redis_multi_az_enabled
      encryption_at_rest       = var.redis_at_rest_encryption_enabled
      encryption_in_transit    = var.redis_transit_encryption_enabled
      snapshot_retention_limit = var.redis_snapshot_retention_limit
    }
  }
}
