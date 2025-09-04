# Compute Module Outputs

# Cluster Information
output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_id : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? google_container_cluster.main[0].id : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].id : null
  ) : null
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_id : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? google_container_cluster.main[0].name : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].name : null
  ) : null
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_endpoint : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? "https://${google_container_cluster.main[0].endpoint}" : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].kube_config[0].host : null
  ) : null
  sensitive = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate of the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_certificate_authority_data : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? google_container_cluster.main[0].master_auth[0].cluster_ca_certificate : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].kube_config[0].cluster_ca_certificate : null
  ) : null
  sensitive = true
}

output "cluster_token" {
  description = "Authentication token for the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_oidc_issuer_url : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? google_container_cluster.main[0].master_auth[0].access_token : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].kube_config[0].password : null
  ) : null
  sensitive = true
}

output "cluster_version" {
  description = "Version of the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_version : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? google_container_cluster.main[0].master_version : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].kubernetes_version : null
  ) : null
}

output "cluster_status" {
  description = "Status of the Kubernetes cluster"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_status : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? google_container_cluster.main[0].status : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].kubernetes_version : null
  ) : null
}

# OIDC Configuration
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_oidc_issuer_url : null
  ) : null
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].oidc_provider_arn : null
  ) : null
}

# Node Information
output "node_groups" {
  description = "Map of node group information"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].eks_managed_node_groups : {}
    ) : var.cloud_provider == "gcp" ? (
    { for pool in google_container_node_pool.main : pool.name => {
      name       = pool.name
      status     = pool.status
      node_count = pool.node_count
      version    = pool.version
    } }
    ) : var.cloud_provider == "azure" ? (
    { for pool in azurerm_kubernetes_cluster_node_pool.main : pool.name => {
      name       = pool.name
      node_count = pool.node_count
      vm_size    = pool.vm_size
    } }
  ) : {}
}

output "node_security_group_id" {
  description = "ID of the node security group"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].node_security_group_id : null
  ) : null
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? module.eks[0].cluster_security_group_id : null
  ) : null
}

# Load Balancer Information
output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? "auto-assigned" : null
    ) : var.cloud_provider == "gcp" ? (
    "auto-assigned"
    ) : var.cloud_provider == "azure" ? (
    "auto-assigned"
  ) : null
}

# Service Account Information (GCP)
output "gke_service_account_email" {
  description = "Email of the GKE service account"
  value = var.cloud_provider == "gcp" ? (
    length(google_service_account.gke_nodes) > 0 ? google_service_account.gke_nodes[0].email : null
  ) : null
}

# Azure-specific outputs
output "kubelet_identity" {
  description = "The Kubelet Identity used by the cluster"
  value = var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].kubelet_identity : null
  ) : null
}

output "cluster_identity" {
  description = "The Cluster Identity used by the cluster"
  value = var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? azurerm_kubernetes_cluster.main[0].identity : null
  ) : null
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value = var.cloud_provider == "azure" ? (
    length(azurerm_log_analytics_workspace.aks) > 0 ? azurerm_log_analytics_workspace.aks[0].id : null
  ) : null
}

# KMS/Encryption Information
output "cluster_encryption_key_arn" {
  description = "ARN of the cluster encryption key"
  value = var.cloud_provider == "aws" ? (
    length(aws_kms_key.eks) > 0 ? aws_kms_key.eks[0].arn : null
  ) : null
}

output "cluster_encryption_key_id" {
  description = "ID of the cluster encryption key"
  value = var.cloud_provider == "gcp" ? (
    length(google_kms_crypto_key.gke) > 0 ? google_kms_crypto_key.gke[0].id : null
  ) : null
}

# Configuration for kubectl
output "kubectl_config" {
  description = "kubectl configuration"
  value = var.cloud_provider == "aws" ? (
    length(module.eks) > 0 ? {
      cluster_name   = module.eks[0].cluster_id
      endpoint       = module.eks[0].cluster_endpoint
      ca_certificate = module.eks[0].cluster_certificate_authority_data
      aws_region     = var.region
      aws_profile    = null
    } : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? {
      cluster_name   = google_container_cluster.main[0].name
      endpoint       = google_container_cluster.main[0].endpoint
      ca_certificate = google_container_cluster.main[0].master_auth[0].cluster_ca_certificate
      location       = google_container_cluster.main[0].location
    } : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? {
      cluster_name    = azurerm_kubernetes_cluster.main[0].name
      resource_group  = azurerm_kubernetes_cluster.main[0].resource_group_name
      subscription_id = data.azurerm_client_config.current[0].subscription_id
    } : null
  ) : null
  sensitive = true
}

# Additional Azure data source for subscription info
data "azurerm_client_config" "current" {
  count    = var.cloud_provider == "azure" ? 1 : 0
  provider = azurerm
}

# Cluster Autoscaler Information
output "cluster_autoscaler_settings" {
  description = "Cluster autoscaler configuration"
  value = {
    enabled   = var.enable_cluster_autoscaler
    min_nodes = var.min_nodes
    max_nodes = var.max_nodes
  }
}

# Network Configuration
output "cluster_network_config" {
  description = "Cluster network configuration"
  value = var.cloud_provider == "gcp" ? (
    length(google_container_cluster.main) > 0 ? {
      network                = google_container_cluster.main[0].network
      subnetwork             = google_container_cluster.main[0].subnetwork
      cluster_ipv4_cidr      = google_container_cluster.main[0].cluster_ipv4_cidr
      services_ipv4_cidr     = google_container_cluster.main[0].services_ipv4_cidr
      master_ipv4_cidr_block = google_container_cluster.main[0].private_cluster_config[0].master_ipv4_cidr_block
    } : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_kubernetes_cluster.main) > 0 ? {
      network_plugin     = azurerm_kubernetes_cluster.main[0].network_profile[0].network_plugin
      network_policy     = azurerm_kubernetes_cluster.main[0].network_profile[0].network_policy
      service_cidr       = azurerm_kubernetes_cluster.main[0].network_profile[0].service_cidr
      dns_service_ip     = azurerm_kubernetes_cluster.main[0].network_profile[0].dns_service_ip
      docker_bridge_cidr = azurerm_kubernetes_cluster.main[0].network_profile[0].docker_bridge_cidr
    } : null
  ) : null
}
