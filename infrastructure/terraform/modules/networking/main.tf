# Networking Module - Multi-cloud VPC and Networking Configuration
# Supports AWS, GCP, and Azure with best practices for security and performance

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
  }
}

# Local variables for networking configuration
locals {
  vpc_cidr = var.cloud_provider == "aws" ? "10.0.0.0/16" : (
    var.cloud_provider == "gcp" ? "10.0.0.0/16" : "10.0.0.0/16"
  )

  private_subnets = var.cloud_provider == "aws" ? [
    "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"
    ] : var.cloud_provider == "gcp" ? [
    "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"
    ] : [
    "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"
  ]

  public_subnets = var.cloud_provider == "aws" ? [
    "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"
    ] : var.cloud_provider == "gcp" ? [
    "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"
    ] : [
    "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"
  ]

  availability_zones = var.cloud_provider == "aws" ? [
    "${var.region}a", "${var.region}b", "${var.region}c"
    ] : var.cloud_provider == "gcp" ? [
    "${var.region}-a", "${var.region}-b", "${var.region}-c"
    ] : [
    "1", "2", "3"
  ]

  common_tags = merge(var.tags, {
    Module = "networking"
  })
}

# AWS VPC Configuration
resource "aws_vpc" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })

  provider = aws
}

resource "aws_internet_gateway" "main" {
  count = var.cloud_provider == "aws" ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })

  provider = aws
}

resource "aws_subnet" "private" {
  count = var.cloud_provider == "aws" ? length(local.private_subnets) : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name                                                           = "${var.project_name}-${var.environment}-private-${count.index + 1}"
    Type                                                           = "private"
    "kubernetes.io/role/internal-elb"                              = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  })

  provider = aws
}

resource "aws_subnet" "public" {
  count = var.cloud_provider == "aws" ? length(local.public_subnets) : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = local.public_subnets[count.index]
  availability_zone = local.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                                                           = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    Type                                                           = "public"
    "kubernetes.io/role/elb"                                       = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  })

  provider = aws
}

resource "aws_nat_gateway" "main" {
  count = var.cloud_provider == "aws" ? length(local.public_subnets) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]

  provider = aws
}

resource "aws_eip" "nat" {
  count = var.cloud_provider == "aws" ? length(local.public_subnets) : 0

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.main]

  provider = aws
}

resource "aws_route_table" "private" {
  count = var.cloud_provider == "aws" ? length(local.private_subnets) : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
  })

  provider = aws
}

resource "aws_route_table" "public" {
  count = var.cloud_provider == "aws" ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
  })

  provider = aws
}

resource "aws_route_table_association" "private" {
  count = var.cloud_provider == "aws" ? length(local.private_subnets) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id

  provider = aws
}

resource "aws_route_table_association" "public" {
  count = var.cloud_provider == "aws" ? length(local.public_subnets) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id

  provider = aws
}

# GCP VPC Configuration
resource "google_compute_network" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460

  provider = google
}

resource "google_compute_subnetwork" "private" {
  count = var.cloud_provider == "gcp" ? length(local.private_subnets) : 0

  name          = "${var.project_name}-${var.environment}-private-${count.index + 1}"
  ip_cidr_range = local.private_subnets[count.index]
  region        = var.region
  network       = google_compute_network.main[0].id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.${count.index + 10}.0.0/14"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.${count.index + 20}.0.0/20"
  }

  provider = google
}

resource "google_compute_subnetwork" "public" {
  count = var.cloud_provider == "gcp" ? length(local.public_subnets) : 0

  name          = "${var.project_name}-${var.environment}-public-${count.index + 1}"
  ip_cidr_range = local.public_subnets[count.index]
  region        = var.region
  network       = google_compute_network.main[0].id

  provider = google
}

resource "google_compute_router" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name    = "${var.project_name}-${var.environment}-router"
  region  = var.region
  network = google_compute_network.main[0].id

  provider = google
}

resource "google_compute_router_nat" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name                               = "${var.project_name}-${var.environment}-nat"
  router                             = google_compute_router.main[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  provider = google
}

# Azure Virtual Network Configuration
resource "azurerm_resource_group" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name     = "${var.project_name}-${var.environment}-rg"
  location = var.region

  tags = local.common_tags

  provider = azurerm
}

resource "azurerm_virtual_network" "main" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = "${var.project_name}-${var.environment}-vnet"
  address_space       = [local.vpc_cidr]
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name

  tags = local.common_tags

  provider = azurerm
}

resource "azurerm_subnet" "private" {
  count = var.cloud_provider == "azure" ? length(local.private_subnets) : 0

  name                 = "${var.project_name}-${var.environment}-private-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [local.private_subnets[count.index]]

  provider = azurerm
}

resource "azurerm_subnet" "public" {
  count = var.cloud_provider == "azure" ? length(local.public_subnets) : 0

  name                 = "${var.project_name}-${var.environment}-public-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [local.public_subnets[count.index]]

  provider = azurerm
}

resource "azurerm_public_ip" "nat" {
  count = var.cloud_provider == "azure" ? length(local.public_subnets) : 0

  name                = "${var.project_name}-${var.environment}-nat-pip-${count.index + 1}"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = local.common_tags

  provider = azurerm
}

resource "azurerm_nat_gateway" "main" {
  count = var.cloud_provider == "azure" ? length(local.public_subnets) : 0

  name                    = "${var.project_name}-${var.environment}-nat-gateway-${count.index + 1}"
  location                = azurerm_resource_group.main[0].location
  resource_group_name     = azurerm_resource_group.main[0].name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1", "2", "3"]

  tags = local.common_tags

  provider = azurerm
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  count = var.cloud_provider == "azure" ? length(local.public_subnets) : 0

  nat_gateway_id       = azurerm_nat_gateway.main[count.index].id
  public_ip_address_id = azurerm_public_ip.nat[count.index].id

  provider = azurerm
}

resource "azurerm_subnet_nat_gateway_association" "private" {
  count = var.cloud_provider == "azure" ? length(local.private_subnets) : 0

  subnet_id      = azurerm_subnet.private[count.index].id
  nat_gateway_id = azurerm_nat_gateway.main[count.index].id

  provider = azurerm
}

# Security Groups / Firewall Rules
resource "aws_security_group" "eks_cluster" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-eks-cluster-"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks-cluster-sg"
  })

  provider = aws
}

resource "aws_security_group" "eks_nodes" {
  count = var.cloud_provider == "aws" ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-eks-nodes-"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    description = "Node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description     = "Cluster communication"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-eks-nodes-sg"
  })

  provider = aws
}

resource "google_compute_firewall" "gke_cluster" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name    = "${var.project_name}-${var.environment}-gke-cluster"
  network = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = ["443", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-cluster"]

  provider = google
}

resource "google_compute_firewall" "gke_nodes" {
  count = var.cloud_provider == "gcp" ? 1 : 0

  name    = "${var.project_name}-${var.environment}-gke-nodes"
  network = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = ["10250", "30000-32767"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = ["gke-cluster", "gke-nodes"]
  target_tags = ["gke-nodes"]

  provider = google
}

resource "azurerm_network_security_group" "aks_cluster" {
  count = var.cloud_provider == "azure" ? 1 : 0

  name                = "${var.project_name}-${var.environment}-aks-cluster-nsg"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name

  security_rule {
    name                       = "HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags

  provider = azurerm
}
