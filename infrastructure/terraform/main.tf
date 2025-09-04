# Enhanced Terraform configuration for Decision Platform
# Cloud-agnostic setup with advanced patterns and best practices

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.10"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Enhanced backend configuration with remote state management
  backend "s3" {
    bucket         = "decision-terraform-state-${var.environment}"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "decision-terraform-locks-${var.environment}"

    # Workspace separation
    workspace_key_prefix = "env"
  }
}

# Enhanced Variables with comprehensive configuration options
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "cloud_provider" {
  description = "Cloud provider to use (aws, gcp, azure)"
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "gcp", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, gcp, azure."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "decision"
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "Map of node instance types by node group"
  type        = map(string)
  default = {
    system   = "t3.medium"
    workload = "t3.large"
    ml       = "m5.xlarge"
  }
}

variable "min_nodes" {
  description = "Minimum number of nodes in the cluster"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Maximum number of nodes in the cluster"
  type        = number
  default     = 20
}

variable "enable_monitoring" {
  description = "Enable monitoring stack (Prometheus, Grafana)"
  type        = bool
  default     = true
}

variable "enable_ssl" {
  description = "Enable SSL/TLS certificates"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "decision.example.com"
}

variable "enable_backup" {
  description = "Enable backup solution"
  type        = bool
  default     = true
}

variable "enable_secrets_management" {
  description = "Enable secrets management (External Secrets Operator)"
  type        = bool
  default     = true
}

variable "enable_gitops" {
  description = "Enable GitOps with ArgoCD"
  type        = bool
  default     = false
}

variable "enable_service_mesh" {
  description = "Enable Istio service mesh"
  type        = bool
  default     = false
}

variable "enable_policy_engine" {
  description = "Enable Open Policy Agent Gatekeeper"
  type        = bool
  default     = true
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "redis_auth_token" {
  description = "Redis authentication token"
  type        = string
  sensitive   = true
  default     = null
}

variable "enable_multi_region" {
  description = "Enable multi-region deployment"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "monitoring_retention_days" {
  description = "Number of days to retain monitoring data"
  type        = number
  default     = 15
}

variable "cost_allocation_tags" {
  description = "Additional tags for cost allocation"
  type        = map(string)
  default     = {}
}

# Data sources
data "aws_availability_zones" "available" {
  provider = aws.main
  state    = "available"
}

# Local values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  name_prefix = "${var.project_name}-${var.environment}"
}

# AWS Provider Configuration
provider "aws" {
  alias  = "main"
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

# GCP Provider Configuration
provider "google" {
  alias   = "main"
  region  = var.region
  project = var.project_name
}

# Azure Provider Configuration
provider "azurerm" {
  alias = "main"
  features {}
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  cloud_provider = var.cloud_provider
  environment    = var.environment
  project_name   = var.project_name
  region         = var.region

  tags = local.common_tags

  providers = {
    aws     = aws.main
    google  = google.main
    azurerm = azurerm.main
  }
}

# Kubernetes Cluster Module
module "compute" {
  source = "./modules/compute"

  cloud_provider     = var.cloud_provider
  environment        = var.environment
  project_name       = var.project_name
  region             = var.region
  kubernetes_version = var.kubernetes_version
  node_instance_type = var.node_instance_types.workload
  min_nodes          = var.min_nodes
  max_nodes          = var.max_nodes

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  tags = local.common_tags

  providers = {
    aws     = aws.main
    google  = google.main
    azurerm = azurerm.main
  }

  depends_on = [module.networking]
}

# Database Module
module "database" {
  source = "./modules/database"

  cloud_provider = var.cloud_provider
  environment    = var.environment
  project_name   = var.project_name
  region         = var.region

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  postgres_password = var.postgres_password
  redis_auth_token  = var.redis_auth_token

  tags = local.common_tags

  providers = {
    aws     = aws.main
    google  = google.main
    azurerm = azurerm.main
  }

  depends_on = [module.networking]
}

# Storage Module (for ML models and data)
module "storage" {
  source = "./modules/storage"

  cloud_provider = var.cloud_provider
  environment    = var.environment
  project_name   = var.project_name

  common_tags = local.common_tags

  providers = {
    aws     = aws.main
    google  = google.main
    azurerm = azurerm.main
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = module.compute.cluster_endpoint
  cluster_ca_certificate = base64decode(module.compute.cluster_ca_certificate)
  token                  = module.compute.cluster_token
}

provider "helm" {
  # The Helm provider will automatically use the kubernetes provider configuration
}

# Deploy application using Helm
resource "helm_release" "decision_platform" {
  name             = "decision-platform"
  chart            = "../kubernetes/charts/decision"
  namespace        = "decision"
  create_namespace = true

  values = [
    yamlencode({
      environment    = var.environment
      image_tag      = "latest"
      domain_name    = var.domain_name
      database_host  = module.database.database_endpoint
      redis_host     = module.database.redis_endpoint
      storage_bucket = module.storage.storage_bucket_name
    })
  ]

  depends_on = [module.compute]
}

# Monitoring stack (optional)
resource "helm_release" "monitoring" {
  count = var.enable_monitoring ? 1 : 0

  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "45.0.0"

  values = [
    file("${path.module}/helm-values/monitoring.yaml")
  ]

  depends_on = [module.compute]
}

# Ingress Controller
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]

  depends_on = [module.compute]
}

# Cert Manager (for SSL certificates)
resource "helm_release" "cert_manager" {
  count = var.enable_ssl ? 1 : 0

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.13.0"

  values = [
    yamlencode({
      installCRDs = true
    })
  ]

  depends_on = [module.compute]
}

# Outputs
output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = module.compute.cluster_endpoint
  sensitive   = true
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.database_endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "Redis endpoint"
  value       = module.database.redis_endpoint
  sensitive   = true
}

output "storage_bucket" {
  description = "Storage bucket name"
  value       = module.storage.storage_bucket_name
}

output "load_balancer_ip" {
  description = "Load balancer IP address"
  value       = module.compute.load_balancer_ip
}

output "application_url" {
  description = "Application URL"
  value       = var.enable_ssl ? "https://${var.domain_name}" : "http://${var.domain_name}"
}
