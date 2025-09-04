# Compute Module - Multi-cloud Kubernetes Cluster Configuration
# Supports AWS EKS, GCP GKE, and Azure AKS with best practices

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
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Local variables
locals {
  cluster_name = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Module  = "compute"
    Cluster = local.cluster_name
  })

  # Node group configuration
  node_groups = {
    system = {
      instance_types = var.cloud_provider == "aws" ? ["t3.medium"] : (
        var.cloud_provider == "gcp" ? ["e2-medium"] : ["Standard_D2s_v3"]
      )
      capacity_type = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 2
      }
      disk_size = 20
      labels = {
        role = "system"
      }
      taints = []
    }

    workload = {
      instance_types = var.cloud_provider == "aws" ? [var.node_instance_type] : (
        var.cloud_provider == "gcp" ? ["e2-standard-4"] : ["Standard_D4s_v3"]
      )
      capacity_type = "SPOT"
      scaling_config = {
        desired_size = var.min_nodes
        max_size     = var.max_nodes
        min_size     = var.min_nodes
      }
      disk_size = 50
      labels = {
        role = "workload"
      }
      taints = []
    }

    ml = {
      instance_types = var.cloud_provider == "aws" ? ["m5.xlarge"] : (
        var.cloud_provider == "gcp" ? ["n1-standard-4"] : ["Standard_D8s_v3"]
      )
      capacity_type = "ON_DEMAND"
      scaling_config = {
        desired_size = 0
        max_size     = 5
        min_size     = 0
      }
      disk_size = 100
      labels = {
        role                               = "ml"
        "node.kubernetes.io/instance-type" = "ml"
      }
      taints = [
        {
          key    = "ml-workload"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {
  count    = var.cloud_provider == "aws" ? 1 : 0
  provider = aws
}

data "aws_partition" "current" {
  count    = var.cloud_provider == "aws" ? 1 : 0
  provider = aws
}

# TLS private key for Azure AKS
resource "tls_private_key" "aks" {
  count = var.cloud_provider == "azure" ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

# AWS EKS Cluster
module "eks" {
  count = var.cloud_provider == "aws" ? 1 : 0

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Cluster encryption
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks[0].arn
    resources        = ["secrets"]
  }

  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    for name, config in local.node_groups : name => {
      name = "${local.cluster_name}-${name}"

      instance_types = config.instance_types
      capacity_type  = config.capacity_type

      min_size     = config.scaling_config.min_size
      max_size     = config.scaling_config.max_size
      desired_size = config.scaling_config.desired_size

      disk_size = config.disk_size
      disk_type = "gp3"

      labels = config.labels
      taints = config.taints

      update_config = {
        max_unavailable_percentage = 25
      }

      # Use custom launch template for advanced configurations
      use_custom_launch_template = true

      # Block device mappings
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = config.disk_size
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = aws_kms_key.eks[0].arn
            delete_on_termination = true
          }
        }
      }

      # Remote access
      remote_access = {
        ec2_ssh_key               = var.key_pair_name
        source_security_group_ids = []
      }

      # Tags
      tags = merge(local.common_tags, {
        NodeGroup = name
      })
    }
  }

  # Cluster security group additional rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Node groups to cluster API"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Node security group additional rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles    = var.aws_auth_roles
  aws_auth_users    = var.aws_auth_users
  aws_auth_accounts = var.aws_auth_accounts

  tags = local.common_tags

  providers = {
    aws = aws
  }
}

# KMS key for EKS encryption
resource "aws_kms_key" "eks" {
  count = var.cloud_provider == "aws" ? 1 : 0

  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-kms-key"
  })

  provider = aws
}

resource "aws_kms_alias" "eks" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name          = "alias/${local.cluster_name}-kms-key"
  target_key_id = aws_kms_key.eks[0].key_id

  provider = aws
}

# GCP GKE Cluster
resource "google_container_cluster" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = local.cluster_name
  location = var.region

  # Regional cluster for high availability
  node_locations = [
    "${var.region}-a",
    "${var.region}-b",
    "${var.region}-c"
  ]

  # Kubernetes version
  min_master_version = var.kubernetes_version

  # Network configuration
  network    = var.vpc_id
  subnetwork = var.subnet_ids[0]

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  # Network policy
  network_policy {
    enabled = true
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_name}.svc.id.goog"
  }

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"

    master_global_access_config {
      enabled = true
    }
  }

  # Database encryption
  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.gke[0].id
  }

  # Release channel for automatic updates
  release_channel {
    channel = "REGULAR"
  }

  # Cluster features
  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }

    gcp_filestore_csi_driver_config {
      enabled = true
    }

    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }

  # Master auth configuration
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Maintenance policy
  maintenance_policy {
    recurring_window {
      start_time = "2023-01-01T02:00:00Z"
      end_time   = "2023-01-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA"
    }
  }

  # Resource labels
  resource_labels = local.common_tags

  # Deletion protection
  deletion_protection = var.environment == "production"

  provider = google
}

# GKE Node Pools
resource "google_container_node_pool" "main" {
  for_each = var.cloud_provider == "gcp" ? local.node_groups : {}

  name     = "${local.cluster_name}-${each.key}"
  location = var.region
  cluster  = google_container_cluster.main[0].name

  # Node count configuration
  node_count = each.value.scaling_config.desired_size

  # Autoscaling
  autoscaling {
    min_node_count = each.value.scaling_config.min_size
    max_node_count = each.value.scaling_config.max_size
  }

  # Node configuration
  node_config {
    preemptible  = each.value.capacity_type == "SPOT"
    machine_type = each.value.instance_types[0]
    disk_size_gb = each.value.disk_size
    disk_type    = "pd-ssd"

    # Service account
    service_account = google_service_account.gke_nodes[0].email
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Labels and taints
    labels = merge(each.value.labels, {
      "cluster"     = local.cluster_name
      "environment" = var.environment
    })

    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Security configurations
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    tags = ["gke-nodes", local.cluster_name]
  }

  # Node management
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Upgrade settings
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  provider = google
}

# GCP Service Account for GKE nodes
resource "google_service_account" "gke_nodes" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  account_id   = "${local.cluster_name}-nodes"
  display_name = "GKE Nodes Service Account"

  provider = google
}

# KMS key for GKE encryption
resource "google_kms_key_ring" "gke" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = "${local.cluster_name}-keyring"
  location = "global"

  provider = google
}

resource "google_kms_crypto_key" "gke" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name     = "${local.cluster_name}-key"
  key_ring = google_kms_key_ring.gke[0].id

  lifecycle {
    prevent_destroy = true
  }

  provider = google
}

# Azure AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = local.cluster_name
  location            = var.region
  resource_group_name = var.resource_group_name
  dns_prefix          = "${local.cluster_name}-dns"

  kubernetes_version = var.kubernetes_version

  # Default node pool
  default_node_pool {
    name       = "system"
    node_count = local.node_groups.system.scaling_config.desired_size
    vm_size    = local.node_groups.system.instance_types[0]

    # Auto-scaling
    auto_scaling_enabled = true
    min_count            = local.node_groups.system.scaling_config.min_size
    max_count            = local.node_groups.system.scaling_config.max_size

    # Networking
    vnet_subnet_id = var.subnet_ids[0]

    # Node configuration
    os_disk_size_gb = local.node_groups.system.disk_size
    os_disk_type    = "Premium_LRS"

    # Only system workloads
    only_critical_addons_enabled = true

    # Upgrade settings
    upgrade_settings {
      max_surge = "1"
    }

    node_labels = local.node_groups.system.labels

    tags = local.common_tags
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  # Network profile
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # RBAC and Azure AD integration
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.aks_admin_group_object_ids
  }

  # API server access profile
  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  # OMS agent for monitoring
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks[0].id
  }

  # Key vault secrets provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Auto-scaler profile
  auto_scaler_profile {
    balance_similar_node_groups      = false
    expander                         = "random"
    max_graceful_termination_sec     = "600"
    max_node_provisioning_time       = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scan_interval                    = "10s"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = "0.5"
    empty_bulk_delete_max            = "10"
    skip_nodes_with_local_storage    = false
    skip_nodes_with_system_pods      = true
  }

  tags = local.common_tags

  provider = azurerm
}

# AKS Additional Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each = var.cloud_provider == "azure" ? { for k, v in local.node_groups : k => v if k != "system" } : {}

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main[0].id
  vm_size               = each.value.instance_types[0]

  # Scaling configuration
  node_count           = each.value.scaling_config.desired_size
  auto_scaling_enabled = true
  min_count            = each.value.scaling_config.min_size
  max_count            = each.value.scaling_config.max_size

  # Networking
  vnet_subnet_id = var.subnet_ids[0]

  # Node configuration
  os_disk_size_gb = each.value.disk_size
  os_disk_type    = "Premium_LRS"
  os_type         = "Linux"

  # Spot instances
  priority        = each.value.capacity_type == "SPOT" ? "Spot" : "Regular"
  eviction_policy = each.value.capacity_type == "SPOT" ? "Delete" : null
  spot_max_price  = each.value.capacity_type == "SPOT" ? -1 : null

  # Labels and taints
  node_labels = each.value.labels

  dynamic "node_taints" {
    for_each = each.value.taints
    content {
      key    = node_taints.value.key
      value  = node_taints.value.value
      effect = node_taints.value.effect
    }
  }

  # Upgrade settings
  upgrade_settings {
    max_surge = "1"
  }

  tags = merge(local.common_tags, {
    NodePool = each.key
  })

  provider = azurerm
}

# Log Analytics Workspace for AKS
resource "azurerm_log_analytics_workspace" "aks" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = "${local.cluster_name}-logs"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags

  provider = azurerm
}
