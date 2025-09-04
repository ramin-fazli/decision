# Storage Module - Multi-cloud storage infrastructure
# This module provisions cloud storage with encryption, lifecycle policies, and monitoring

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# AWS S3 Storage Configuration
resource "aws_s3_bucket" "decision_storage" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  bucket = "${var.project_name}-${var.environment}-storage"

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-storage"
    Environment = var.environment
    Type        = "storage"
  })
}

resource "aws_s3_bucket_versioning" "decision_storage_versioning" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  bucket = aws_s3_bucket.decision_storage[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "decision_storage_encryption" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  bucket = aws_s3_bucket.decision_storage[0].id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.storage_key[0].arn
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "decision_storage_lifecycle" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  bucket = aws_s3_bucket.decision_storage[0].id

  rule {
    id     = "decision_lifecycle"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
  }

  rule {
    id     = "ml_models_lifecycle"
    status = "Enabled"

    filter {
      prefix = "ml-models/"
    }

    transition {
      days          = 7
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }

  rule {
    id     = "logs_lifecycle"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "decision_storage_pab" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  bucket = aws_s3_bucket.decision_storage[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "decision_storage_notification" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  bucket = aws_s3_bucket.decision_storage[0].id

  eventbridge = true

  lambda_function {
    lambda_function_arn = aws_lambda_function.storage_processor[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".csv"
  }
}

# KMS Key for S3 encryption
resource "aws_kms_key" "storage_key" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  description = "KMS key for Decision Platform storage encryption"

  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-storage-key"
  })
}

resource "aws_kms_alias" "storage_key_alias" {
  count         = var.cloud_provider == "aws" ? 1 : 0
  name          = "alias/${var.project_name}-${var.environment}-storage"
  target_key_id = aws_kms_key.storage_key[0].key_id
}

# Lambda function for storage processing
resource "aws_lambda_function" "storage_processor" {
  count         = var.cloud_provider == "aws" ? 1 : 0
  filename      = "storage_processor.zip"
  function_name = "${var.project_name}-${var.environment}-storage-processor"
  role          = aws_iam_role.lambda_storage_role[0].arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 300

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.decision_storage[0].bucket
      KMS_KEY_ID  = aws_kms_key.storage_key[0].arn
    }
  }

  tags = var.common_tags
}

resource "aws_iam_role" "lambda_storage_role" {
  count = var.cloud_provider == "aws" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-lambda-storage-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Google Cloud Storage Configuration
resource "google_storage_bucket" "decision_storage" {
  count         = var.cloud_provider == "gcp" ? 1 : 0
  name          = "${var.project_name}-${var.environment}-storage"
  location      = var.gcp_region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.storage_key[0].id
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  lifecycle_rule {
    condition {
      age            = 7
      matches_prefix = ["logs/"]
      with_state     = "LIVE"
    }
    action {
      type = "Delete"
    }
  }

  labels = var.common_tags
}

resource "google_kms_key_ring" "storage_key_ring" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  name     = "${var.project_name}-${var.environment}-storage"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "storage_key" {
  count           = var.cloud_provider == "gcp" ? 1 : 0
  name            = "storage-key"
  key_ring        = google_kms_key_ring.storage_key_ring[0].id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

# Azure Storage Configuration
resource "azurerm_storage_account" "decision_storage" {
  count                    = var.cloud_provider == "azure" ? 1 : 0
  name                     = replace("${var.project_name}${var.environment}storage", "-", "")
  resource_group_name      = var.azure_resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 7
    last_access_time_enabled      = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  tags = var.common_tags
}

resource "azurerm_storage_container" "decision_storage_container" {
  count                 = var.cloud_provider == "azure" ? 1 : 0
  name                  = "decision-data"
  storage_account_id    = azurerm_storage_account.decision_storage[0].id
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "decision_storage_policy" {
  count              = var.cloud_provider == "azure" ? 1 : 0
  storage_account_id = azurerm_storage_account.decision_storage[0].id

  rule {
    name    = "decision_lifecycle"
    enabled = true
    filters {
      prefix_match = ["decision-data/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 2555 # 7 years
      }
      version {
        delete_after_days_since_creation = 90
      }
    }
  }

  rule {
    name    = "ml_models_lifecycle"
    enabled = true
    filters {
      prefix_match = ["decision-data/ml-models/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 7
        tier_to_archive_after_days_since_modification_greater_than = 30
      }
    }
  }

  rule {
    name    = "logs_lifecycle"
    enabled = true
    filters {
      prefix_match = ["decision-data/logs/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }
    }
  }
}

# Monitoring and Alerting for Storage
resource "aws_cloudwatch_metric_alarm" "s3_storage_size" {
  count               = var.cloud_provider == "aws" ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-s3-storage-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400"
  statistic           = "Average"
  threshold           = "107374182400" # 100GB in bytes
  alarm_description   = "This metric monitors S3 bucket size"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    BucketName  = aws_s3_bucket.decision_storage[0].bucket
    StorageType = "StandardStorage"
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "s3_number_of_objects" {
  count               = var.cloud_provider == "aws" ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-s3-object-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = "86400"
  statistic           = "Average"
  threshold           = "1000000" # 1 million objects
  alarm_description   = "This metric monitors S3 object count"
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    BucketName  = aws_s3_bucket.decision_storage[0].bucket
    StorageType = "AllStorageTypes"
  }

  tags = var.common_tags
}

# Data backup configuration
resource "aws_s3_bucket" "decision_backup" {
  count  = var.cloud_provider == "aws" && var.enable_backup ? 1 : 0
  bucket = "${var.project_name}-${var.environment}-backup"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-backup"
    Type = "backup"
  })
}

resource "aws_s3_bucket_replication_configuration" "decision_backup_replication" {
  count  = var.cloud_provider == "aws" && var.enable_backup ? 1 : 0
  role   = aws_iam_role.s3_replication_role[0].arn
  bucket = aws_s3_bucket.decision_storage[0].id

  rule {
    id     = "backup_replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.decision_backup[0].arn
      storage_class = "GLACIER"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.storage_key[0].arn
      }
    }
  }
}

resource "aws_iam_role" "s3_replication_role" {
  count = var.cloud_provider == "aws" && var.enable_backup ? 1 : 0
  name  = "${var.project_name}-${var.environment}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}
