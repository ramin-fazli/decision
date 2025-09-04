# Networking Module Outputs

# VPC/Network Outputs
output "vpc_id" {
  description = "ID of the VPC/Virtual Network"
  value = var.cloud_provider == "aws" ? (
    length(aws_vpc.main) > 0 ? aws_vpc.main[0].id : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_compute_network.main) > 0 ? google_compute_network.main[0].id : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_virtual_network.main) > 0 ? azurerm_virtual_network.main[0].id : null
  ) : null
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value = var.cloud_provider == "aws" ? (
    length(aws_vpc.main) > 0 ? aws_vpc.main[0].cidr_block : null
    ) : var.cloud_provider == "gcp" ? (
    local.vpc_cidr
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_virtual_network.main) > 0 ? azurerm_virtual_network.main[0].address_space[0] : null
  ) : null
}

output "vpc_name" {
  description = "Name of the VPC/Virtual Network"
  value = var.cloud_provider == "aws" ? (
    length(aws_vpc.main) > 0 ? aws_vpc.main[0].tags["Name"] : null
    ) : var.cloud_provider == "gcp" ? (
    length(google_compute_network.main) > 0 ? google_compute_network.main[0].name : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_virtual_network.main) > 0 ? azurerm_virtual_network.main[0].name : null
  ) : null
}

# Private Subnet Outputs
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value = var.cloud_provider == "aws" ? aws_subnet.private[*].id : (
    var.cloud_provider == "gcp" ? google_compute_subnetwork.private[*].id : (
      var.cloud_provider == "azure" ? azurerm_subnet.private[*].id : []
    )
  )
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value = var.cloud_provider == "aws" ? aws_subnet.private[*].cidr_block : (
    var.cloud_provider == "gcp" ? google_compute_subnetwork.private[*].ip_cidr_range : (
      var.cloud_provider == "azure" ? azurerm_subnet.private[*].address_prefixes[0] : []
    )
  )
}

output "private_subnet_availability_zones" {
  description = "Availability zones of the private subnets"
  value = var.cloud_provider == "aws" ? aws_subnet.private[*].availability_zone : (
    var.cloud_provider == "gcp" ? local.availability_zones : (
      var.cloud_provider == "azure" ? local.availability_zones : []
    )
  )
}

# Public Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value = var.cloud_provider == "aws" ? aws_subnet.public[*].id : (
    var.cloud_provider == "gcp" ? google_compute_subnetwork.public[*].id : (
      var.cloud_provider == "azure" ? azurerm_subnet.public[*].id : []
    )
  )
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value = var.cloud_provider == "aws" ? aws_subnet.public[*].cidr_block : (
    var.cloud_provider == "gcp" ? google_compute_subnetwork.public[*].ip_cidr_range : (
      var.cloud_provider == "azure" ? azurerm_subnet.public[*].address_prefixes[0] : []
    )
  )
}

output "public_subnet_availability_zones" {
  description = "Availability zones of the public subnets"
  value = var.cloud_provider == "aws" ? aws_subnet.public[*].availability_zone : (
    var.cloud_provider == "gcp" ? local.availability_zones : (
      var.cloud_provider == "azure" ? local.availability_zones : []
    )
  )
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value = var.cloud_provider == "aws" ? (
    length(aws_internet_gateway.main) > 0 ? aws_internet_gateway.main[0].id : null
  ) : null
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value = var.cloud_provider == "aws" ? aws_nat_gateway.main[*].id : (
    var.cloud_provider == "gcp" ? google_compute_router_nat.main[*].name : (
      var.cloud_provider == "azure" ? azurerm_nat_gateway.main[*].id : []
    )
  )
}

output "nat_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value = var.cloud_provider == "aws" ? aws_eip.nat[*].public_ip : (
    var.cloud_provider == "azure" ? azurerm_public_ip.nat[*].ip_address : []
  )
}

# Security Group Outputs
output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value = var.cloud_provider == "aws" ? (
    length(aws_security_group.eks_cluster) > 0 ? aws_security_group.eks_cluster[0].id : null
    ) : var.cloud_provider == "azure" ? (
    length(azurerm_network_security_group.aks_cluster) > 0 ? azurerm_network_security_group.aks_cluster[0].id : null
  ) : null
}

output "nodes_security_group_id" {
  description = "ID of the nodes security group"
  value = var.cloud_provider == "aws" ? (
    length(aws_security_group.eks_nodes) > 0 ? aws_security_group.eks_nodes[0].id : null
  ) : null
}

# Route Table Outputs
output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = var.cloud_provider == "aws" ? aws_route_table.private[*].id : []
}

output "public_route_table_ids" {
  description = "IDs of the public route tables"
  value       = var.cloud_provider == "aws" ? aws_route_table.public[*].id : []
}

# Resource Group Output (Azure)
output "resource_group_name" {
  description = "Name of the resource group (Azure only)"
  value = var.cloud_provider == "azure" ? (
    length(azurerm_resource_group.main) > 0 ? azurerm_resource_group.main[0].name : null
  ) : null
}

output "resource_group_location" {
  description = "Location of the resource group (Azure only)"
  value = var.cloud_provider == "azure" ? (
    length(azurerm_resource_group.main) > 0 ? azurerm_resource_group.main[0].location : null
  ) : null
}

# Secondary IP Ranges for GKE (GCP only)
output "pod_ip_range_names" {
  description = "Names of the secondary IP ranges for pods (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_subnetwork.private[*].secondary_ip_range[0].range_name : []
}

output "service_ip_range_names" {
  description = "Names of the secondary IP ranges for services (GCP only)"
  value       = var.cloud_provider == "gcp" ? google_compute_subnetwork.private[*].secondary_ip_range[1].range_name : []
}
