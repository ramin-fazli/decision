# Main Terraform configuration for Decision Platform
# Cloud-agnostic setup with support for AWS, GCP, and Azure

terraform {
  required_version = ">= 1.0"
  
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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  # Backend configuration for state management
  backend "s3" {
    bucket         = "decision-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "decision-terraform-locks"
  }
}

# Variables
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
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

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_instance_type" {
  description = "Instance type for Kubernetes nodes"
  type        = string
  default     = "t3.medium"
}

variable "min_nodes" {
  description = "Minimum number of nodes in the cluster"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Maximum number of nodes in the cluster"
  type        = number
  default     = 10
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
  default     = "decision.is"
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
    aws    = aws.main
    google = google.main
    azurerm = azurerm.main
  }
}

# Kubernetes Cluster Module
module "kubernetes" {
  source = "./modules/compute"
  
  cloud_provider     = var.cloud_provider
  environment        = var.environment
  project_name       = var.project_name
  region             = var.region
  kubernetes_version = var.kubernetes_version
  node_instance_type = var.node_instance_type
  min_nodes          = var.min_nodes
  max_nodes          = var.max_nodes
  
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  
  tags = local.common_tags
  
  providers = {
    aws    = aws.main
    google = google.main
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
  
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.private_subnet_ids
  
  tags = local.common_tags
  
  providers = {
    aws    = aws.main
    google = google.main
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
  region         = var.region
  
  tags = local.common_tags
  
  providers = {
    aws    = aws.main
    google = google.main
    azurerm = azurerm.main
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = module.kubernetes.cluster_endpoint
  cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
  token                  = module.kubernetes.cluster_token
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.cluster_endpoint
    cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
    token                  = module.kubernetes.cluster_token
  }
}

# Deploy application using Helm
resource "helm_release" "decision_platform" {
  name       = "decision-platform"
  chart      = "../kubernetes/charts/decision"
  namespace  = "decision"
  create_namespace = true
  
  values = [
    templatefile("${path.module}/helm-values/${var.environment}.yaml", {
      environment     = var.environment
      image_tag       = "latest"
      domain_name     = var.domain_name
      database_host   = module.database.database_endpoint
      redis_host      = module.database.redis_endpoint
      storage_bucket  = module.storage.bucket_name
    })
  ]
  
  depends_on = [module.kubernetes]
}

# Monitoring stack (optional)
resource "helm_release" "monitoring" {
  count = var.enable_monitoring ? 1 : 0
  
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true
  version    = "45.0.0"
  
  values = [
    file("${path.module}/helm-values/monitoring.yaml")
  ]
  
  depends_on = [module.kubernetes]
}

# Ingress Controller
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  
  depends_on = [module.kubernetes]
}

# Cert Manager (for SSL certificates)
resource "helm_release" "cert_manager" {
  count = var.enable_ssl ? 1 : 0
  
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true
  version    = "v1.13.0"
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  depends_on = [module.kubernetes]
}

# Outputs
output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = module.kubernetes.cluster_endpoint
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
  value       = module.storage.bucket_name
}

output "load_balancer_ip" {
  description = "Load balancer IP address"
  value       = module.kubernetes.load_balancer_ip
}

output "application_url" {
  description = "Application URL"
  value       = var.enable_ssl ? "https://${var.domain_name}" : "http://${var.domain_name}"
}
