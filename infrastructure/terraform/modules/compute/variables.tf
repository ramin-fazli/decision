# Compute Module Variables

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

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the cluster"
  type        = list(string)
}

variable "key_pair_name" {
  description = "AWS EC2 Key Pair name for SSH access to nodes"
  type        = string
  default     = null
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = true
}

variable "enable_horizontal_pod_autoscaler" {
  description = "Enable horizontal pod autoscaler"
  type        = bool
  default     = true
}

variable "enable_vertical_pod_autoscaler" {
  description = "Enable vertical pod autoscaler"
  type        = bool
  default     = false
}

variable "enable_metrics_server" {
  description = "Enable metrics server"
  type        = bool
  default     = true
}

variable "enable_cluster_logging" {
  description = "Enable cluster logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain cluster logs"
  type        = number
  default     = 30
}

# AWS-specific variables
variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_accounts" {
  description = "List of account maps to add to the aws-auth configmap"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# GCP-specific variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = null
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation for the hosted master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_private_nodes" {
  description = "Enable private nodes"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint"
  type        = bool
  default     = false
}

# Azure-specific variables
variable "resource_group_name" {
  description = "Name of the resource group (Azure only)"
  type        = string
  default     = null
}

variable "aks_admin_group_object_ids" {
  description = "List of Azure AD group object IDs that will have admin access to AKS"
  type        = list(string)
  default     = []
}

variable "authorized_ip_ranges" {
  description = "List of authorized IP ranges for API server access"
  type        = list(string)
  default     = []
}

variable "enable_azure_rbac" {
  description = "Enable Azure RBAC for AKS"
  type        = bool
  default     = true
}

variable "enable_oms_agent" {
  description = "Enable OMS agent for monitoring"
  type        = bool
  default     = true
}

variable "network_plugin" {
  description = "Network plugin to use for networking (azure, kubenet)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'kubenet'."
  }
}

variable "network_policy" {
  description = "Network policy to use (azure, calico)"
  type        = string
  default     = "azure"

  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be either 'azure' or 'calico'."
  }
}

# Node pool configurations
variable "node_pools" {
  description = "Additional node pools configuration"
  type = map(object({
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    os_disk_size_gb     = number
    enable_auto_scaling = bool
    node_labels         = map(string)
    node_taints         = list(string)
    availability_zones  = list(string)
  }))
  default = {}
}

# Security configurations
variable "enable_encryption_at_rest" {
  description = "Enable encryption at rest for etcd"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "enable_pod_security_policy" {
  description = "Enable pod security policy"
  type        = bool
  default     = false
}

variable "enable_workload_identity" {
  description = "Enable workload identity (GCP only)"
  type        = bool
  default     = true
}

# Monitoring and logging
variable "enable_cluster_monitoring" {
  description = "Enable cluster monitoring"
  type        = bool
  default     = true
}

variable "monitoring_config" {
  description = "Monitoring configuration"
  type = object({
    enable_system_metrics     = bool
    enable_workload_metrics   = bool
    enable_api_server_metrics = bool
    enable_controller_metrics = bool
    enable_scheduler_metrics  = bool
  })
  default = {
    enable_system_metrics     = true
    enable_workload_metrics   = true
    enable_api_server_metrics = true
    enable_controller_metrics = true
    enable_scheduler_metrics  = true
  }
}
