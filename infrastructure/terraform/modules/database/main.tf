# Database Module - Multi-cloud Database Configuration
# Supports AWS RDS, GCP Cloud SQL, and Azure Database with best practices

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Local variables
locals {
  database_name = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Module = "database"
  })

  # Instance sizing based on environment
  postgres_instance_class = var.environment == "production" ? "db.t3.medium" : var.postgres_instance_class
  redis_node_type         = var.environment == "production" ? "cache.t3.small" : var.redis_node_type

  # Security settings
  deletion_protection = var.environment == "production" ? true : var.postgres_deletion_protection
  backup_retention    = var.environment == "production" ? 30 : var.postgres_backup_retention_period
}

# Random password generation for Redis
resource "random_password" "redis_auth_token" {
  count = var.redis_auth_token == null ? 1 : 0

  length  = 32
  special = true
}

# AWS RDS PostgreSQL
resource "aws_db_subnet_group" "postgres" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name       = "${local.database_name}-postgres-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.database_name}-postgres-subnet-group"
  })

  provider = aws
}

resource "aws_security_group" "postgres" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name_prefix = "${local.database_name}-postgres-"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL"
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.database_name}-postgres-sg"
  })

  provider = aws
}

resource "aws_kms_key" "postgres" {
  count = var.cloud_provider == "aws" && var.postgres_storage_encrypted ? 1 : 0

  description             = "KMS key for PostgreSQL encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.database_name}-postgres-kms"
  })

  provider = aws
}

resource "aws_kms_alias" "postgres" {
  count = var.cloud_provider == "aws" && var.postgres_storage_encrypted ? 1 : 0

  name          = "alias/${local.database_name}-postgres"
  target_key_id = aws_kms_key.postgres[0].key_id

  provider = aws
}

resource "aws_db_instance" "postgres" {
  count = var.cloud_provider == "aws" ? 1 : 0

  identifier = "${local.database_name}-postgres"

  # Engine configuration
  engine                = "postgres"
  engine_version        = var.postgres_version
  instance_class        = local.postgres_instance_class
  allocated_storage     = var.postgres_allocated_storage
  max_allocated_storage = var.postgres_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = var.postgres_storage_encrypted
  kms_key_id            = var.postgres_storage_encrypted ? aws_kms_key.postgres[0].arn : null

  # Database configuration
  db_name  = var.postgres_database_name
  username = var.postgres_username
  password = var.postgres_password
  port     = var.postgres_port

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.postgres[0].name
  vpc_security_group_ids = [aws_security_group.postgres[0].id]
  publicly_accessible    = var.postgres_publicly_accessible

  # Backup and maintenance
  backup_retention_period   = local.backup_retention
  backup_window             = var.postgres_backup_window
  maintenance_window        = var.postgres_maintenance_window
  skip_final_snapshot       = var.postgres_skip_final_snapshot
  final_snapshot_identifier = var.postgres_skip_final_snapshot ? null : "${local.database_name}-postgres-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  deletion_protection       = local.deletion_protection

  # High availability
  multi_az = var.postgres_multi_az

  # Monitoring
  performance_insights_enabled          = var.postgres_performance_insights_enabled
  performance_insights_retention_period = var.postgres_performance_insights_retention_period
  monitoring_interval                   = var.postgres_monitoring_interval
  monitoring_role_arn                   = var.postgres_monitoring_interval > 0 ? aws_iam_role.postgres_monitoring[0].arn : null

  # Logging
  enabled_cloudwatch_logs_exports = var.postgres_enable_logging ? ["postgresql"] : []

  # Parameters
  parameter_group_name = aws_db_parameter_group.postgres[0].name

  # Maintenance
  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false

  tags = merge(local.common_tags, {
    Name = "${local.database_name}-postgres"
  })

  provider = aws
}

resource "aws_db_parameter_group" "postgres" {
  count = var.cloud_provider == "aws" ? 1 : 0

  family = "postgres${split(".", var.postgres_version)[0]}"
  name   = "${local.database_name}-postgres-params"

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = local.common_tags

  provider = aws
}

# IAM role for enhanced monitoring
resource "aws_iam_role" "postgres_monitoring" {
  count = var.cloud_provider == "aws" && var.postgres_monitoring_interval > 0 ? 1 : 0

  name = "${local.database_name}-postgres-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags

  provider = aws
}

resource "aws_iam_role_policy_attachment" "postgres_monitoring" {
  count = var.cloud_provider == "aws" && var.postgres_monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.postgres_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"

  provider = aws
}

# AWS ElastiCache Redis
resource "aws_elasticache_subnet_group" "redis" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name       = "${local.database_name}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = local.common_tags

  provider = aws
}

resource "aws_security_group" "redis" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name_prefix = "${local.database_name}-redis-"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis"
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.database_name}-redis-sg"
  })

  provider = aws
}

resource "aws_elasticache_replication_group" "redis" {
  count = var.cloud_provider == "aws" ? 1 : 0

  replication_group_id = "${local.database_name}-redis"
  description          = "Redis cluster for ${local.database_name}"

  # Engine configuration
  engine               = "redis"
  engine_version       = var.redis_version
  node_type            = local.redis_node_type
  port                 = var.redis_port
  parameter_group_name = aws_elasticache_parameter_group.redis[0].name

  # Cluster configuration
  num_cache_clusters         = var.redis_num_cache_nodes
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  multi_az_enabled           = var.redis_multi_az_enabled

  # Network configuration
  subnet_group_name  = aws_elasticache_subnet_group.redis[0].name
  security_group_ids = [aws_security_group.redis[0].id]

  # Security
  at_rest_encryption_enabled = var.redis_at_rest_encryption_enabled
  transit_encryption_enabled = var.redis_transit_encryption_enabled
  auth_token                 = var.redis_transit_encryption_enabled ? (var.redis_auth_token != null ? var.redis_auth_token : random_password.redis_auth_token[0].result) : null

  # Backup and maintenance
  snapshot_retention_limit = var.redis_snapshot_retention_limit
  snapshot_window          = var.redis_snapshot_window
  maintenance_window       = var.redis_maintenance_window

  # Notifications
  notification_topic_arn = var.enable_monitoring ? aws_sns_topic.database_alerts[0].arn : null

  # Logging
  dynamic "log_delivery_configuration" {
    for_each = var.redis_log_delivery_configuration
    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.database_name}-redis"
  })

  provider = aws
}

resource "aws_elasticache_parameter_group" "redis" {
  count = var.cloud_provider == "aws" ? 1 : 0

  family = "redis${split(".", var.redis_version)[0]}"
  name   = "${local.database_name}-redis-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  tags = local.common_tags

  provider = aws
}

# GCP Cloud SQL PostgreSQL
resource "google_sql_database_instance" "postgres" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name             = "${local.database_name}-postgres"
  database_version = "POSTGRES_${replace(var.postgres_version, ".", "_")}"
  region           = var.region

  settings {
    tier                  = "db-f1-micro"
    availability_type     = var.postgres_multi_az ? "REGIONAL" : "ZONAL"
    disk_size             = var.postgres_allocated_storage
    disk_type             = "PD_SSD"
    disk_autoresize       = true
    disk_autoresize_limit = var.postgres_max_allocated_storage

    backup_configuration {
      enabled                        = var.enable_automated_backup
      start_time                     = "03:00"
      point_in_time_recovery_enabled = var.enable_point_in_time_recovery
      backup_retention_settings {
        retained_backups = local.backup_retention
      }
    }

    ip_configuration {
      ipv4_enabled    = var.postgres_publicly_accessible
      private_network = var.vpc_id

      dynamic "authorized_networks" {
        for_each = var.allowed_cidr_blocks
        content {
          value = authorized_networks.value
        }
      }
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 4
      update_track = "stable"
    }

    database_flags {
      name  = "log_statement"
      value = "all"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    insights_config {
      query_insights_enabled  = var.postgres_performance_insights_enabled
      record_application_tags = true
      record_client_address   = true
    }
  }

  deletion_protection = local.deletion_protection

  provider = google
}

resource "google_sql_database" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = var.postgres_database_name
  instance = google_sql_database_instance.postgres[0].name

  provider = google
}

resource "google_sql_user" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = var.postgres_username
  instance = google_sql_database_instance.postgres[0].name
  password = var.postgres_password

  provider = google
}

# GCP Redis (Memorystore)
resource "google_redis_instance" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name           = "${local.database_name}-redis"
  memory_size_gb = 1
  region         = var.region

  redis_version = "REDIS_${replace(var.redis_version, ".", "_")}"
  tier          = var.redis_automatic_failover_enabled ? "STANDARD_HA" : "BASIC"

  auth_enabled            = var.redis_transit_encryption_enabled
  transit_encryption_mode = var.redis_transit_encryption_enabled ? "SERVER_AUTHENTICATION" : "DISABLED"

  authorized_network = var.vpc_id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 4
        minutes = 0
      }
    }
  }

  provider = google
}

# Azure Database for PostgreSQL
resource "azurerm_postgresql_flexible_server" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = "${local.database_name}-postgres"
  resource_group_name = var.resource_group_name
  location            = var.region

  version                = var.postgres_version
  administrator_login    = var.postgres_username
  administrator_password = var.postgres_password

  sku_name   = "B_Standard_B1ms"
  storage_mb = var.postgres_allocated_storage * 1024

  backup_retention_days        = local.backup_retention
  geo_redundant_backup_enabled = var.enable_cross_region_backup

  high_availability {
    mode = var.postgres_multi_az ? "ZoneRedundant" : "Disabled"
  }

  maintenance_window {
    day_of_week  = 0 # Sunday
    start_hour   = 4
    start_minute = 0
  }

  tags = local.common_tags

  provider = azurerm
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name      = var.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.main[0].id
  collation = "en_US.utf8"
  charset   = "utf8"

  provider = azurerm
}

# Azure Cache for Redis
resource "azurerm_redis_cache" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = "${local.database_name}-redis"
  location            = var.region
  resource_group_name = var.resource_group_name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"

  redis_version       = var.redis_version
  minimum_tls_version = var.ssl_minimal_tls_version

  patch_schedule {
    day_of_week    = "Sunday"
    start_hour_utc = 4
  }

  tags = local.common_tags

  provider = azurerm
}

# Monitoring and Alerting
resource "aws_sns_topic" "database_alerts" {
  count = var.cloud_provider == "aws" && var.enable_monitoring ? 1 : 0

  name = "${local.database_name}-database-alerts"

  tags = local.common_tags

  provider = aws
}

resource "aws_cloudwatch_metric_alarm" "postgres_cpu" {
  count = var.cloud_provider == "aws" && var.enable_cpu_utilization_alarm ? 1 : 0

  alarm_name          = "${local.database_name}-postgres-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = [aws_sns_topic.database_alerts[0].arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres[0].id
  }

  tags = local.common_tags

  provider = aws
}

resource "aws_cloudwatch_metric_alarm" "postgres_connections" {
  count = var.cloud_provider == "aws" && var.enable_connection_count_alarm ? 1 : 0

  alarm_name          = "${local.database_name}-postgres-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.connection_count_threshold
  alarm_description   = "This metric monitors RDS connection count"
  alarm_actions       = [aws_sns_topic.database_alerts[0].arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres[0].id
  }

  tags = local.common_tags

  provider = aws
}

resource "aws_cloudwatch_metric_alarm" "postgres_free_storage" {
  count = var.cloud_provider == "aws" && var.enable_free_storage_space_alarm ? 1 : 0

  alarm_name          = "${local.database_name}-postgres-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.free_storage_space_threshold
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = [aws_sns_topic.database_alerts[0].arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres[0].id
  }

  tags = local.common_tags

  provider = aws
}

# Read Replicas
resource "aws_db_instance" "postgres_read_replica" {
  count = var.cloud_provider == "aws" && var.enable_read_replicas ? var.read_replica_count : 0

  identifier = "${local.database_name}-postgres-replica-${count.index + 1}"

  replicate_source_db = aws_db_instance.postgres[0].identifier

  instance_class = local.postgres_instance_class

  publicly_accessible = var.postgres_publicly_accessible

  skip_final_snapshot = true

  tags = merge(local.common_tags, {
    Name = "${local.database_name}-postgres-replica-${count.index + 1}"
    Type = "ReadReplica"
  })

  provider = aws
}
