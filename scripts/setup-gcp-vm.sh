#!/bin/bash

# Decision Platform - GCP VM Setup Script
# This script prepares a GCP VM for Decision Platform deployment

set -e

echo "🚀 Setting up Decision Platform on GCP VM..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Ubuntu
if ! command -v apt-get &> /dev/null; then
    print_error "This script is designed for Ubuntu/Debian systems"
    exit 1
fi

# Update system packages
print_status "Updating system packages..."
sudo apt-get update -qq

# Install required packages
print_status "Installing required packages..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    wget \
    unzip

# Install Docker
if ! command -v docker &> /dev/null; then
    print_status "Installing Docker..."
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update -qq
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    sudo usermod -aG docker ubuntu 2>/dev/null || true
    
    print_status "Docker installed successfully"
else
    print_status "Docker is already installed"
fi

# Install Google Cloud CLI
if ! command -v gcloud &> /dev/null; then
    print_status "Installing Google Cloud CLI..."
    
    # Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    
    # Import the Google Cloud Platform public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    
    # Update the package list and install the Cloud SDK
    sudo apt-get update -qq && sudo apt-get install -y google-cloud-cli
    
    print_status "Google Cloud CLI installed successfully"
else
    print_status "Google Cloud CLI is already installed"
fi

# Create application directory structure
print_status "Creating application directory structure..."
sudo mkdir -p /opt/decision-platform/{logs,uploads,models,data}
sudo chown -R $USER:$USER /opt/decision-platform
chmod -R 755 /opt/decision-platform

# Create docker network
print_status "Creating Docker network..."
docker network create decision-network 2>/dev/null || print_warning "Docker network already exists"

# Check firewall status
print_status "Checking firewall configuration..."
if command -v ufw &> /dev/null; then
    sudo ufw status
    print_warning "Make sure to allow ports 80, 443, 3000, 8000, 5432, 6379, 9000, 9001"
fi

# Display system information
print_status "System Information:"
echo "  OS: $(lsb_release -d | cut -f2)"
echo "  Kernel: $(uname -r)"
echo "  Architecture: $(uname -m)"
echo "  Memory: $(free -h | grep '^Mem:' | awk '{print $2}')"
echo "  Disk Space: $(df -h / | tail -1 | awk '{print $4}') available"

# Display Docker version
if command -v docker &> /dev/null; then
    echo "  Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
fi

# Display gcloud version
if command -v gcloud &> /dev/null; then
    echo "  Google Cloud CLI: $(gcloud version --format='value(Google Cloud SDK)')"
fi

print_status "VM setup completed successfully!"
print_warning "Please log out and log back in to refresh group membership for Docker"

echo ""
echo "Next steps:"
echo "1. Log out and log back in (or run 'newgrp docker')"
echo "2. Authenticate with Google Cloud: gcloud auth login"
echo "3. Set your default project: gcloud config set project YOUR_PROJECT_ID"
echo "4. Configure Docker for Artifact Registry authentication"
echo "5. Run the GitHub Actions deployment workflow"

# Create a simple health check script
print_status "Creating health check script..."
cat > /opt/decision-platform/health-check.sh << 'EOF'
#!/bin/bash

# Decision Platform Health Check Script

echo "🏥 Decision Platform Health Check"
echo "================================="

# Check if containers are running
echo "📊 Container Status:"
if command -v docker-compose &> /dev/null; then
    cd /opt/decision-platform
    if [ -f "docker-compose.prod.yml" ]; then
        docker-compose -f docker-compose.prod.yml ps
    else
        echo "  docker-compose.prod.yml not found"
    fi
else
    echo "  docker-compose not available"
fi

echo ""
echo "🌐 Service Health Checks:"

# Check backend health
if timeout 5 curl -f http://localhost:8000/health >/dev/null 2>&1; then
    echo "  ✅ Backend API: Healthy"
else
    echo "  ❌ Backend API: Unhealthy"
fi

# Check frontend health
if timeout 5 curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "  ✅ Frontend: Healthy"
else
    echo "  ❌ Frontend: Unhealthy"
fi

# Check PostgreSQL
if timeout 5 pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    echo "  ✅ PostgreSQL: Healthy"
else
    echo "  ❌ PostgreSQL: Unhealthy"
fi

# Check Redis
if timeout 5 redis-cli -h localhost -p 6379 ping >/dev/null 2>&1; then
    echo "  ✅ Redis: Healthy"
else
    echo "  ❌ Redis: Unhealthy"
fi

# Check MinIO
if timeout 5 curl -f http://localhost:9000/minio/health/live >/dev/null 2>&1; then
    echo "  ✅ MinIO: Healthy"
else
    echo "  ❌ MinIO: Unhealthy"
fi

echo ""
echo "💾 System Resources:"
echo "  Memory Usage: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2}')"
echo "  Disk Usage: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo "  Load Average: $(uptime | awk -F'load average:' '{print $2}')"

echo ""
echo "🔗 Access URLs:"
# Get external IP if available
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip 2>/dev/null || echo "localhost")
echo "  Frontend: http://$EXTERNAL_IP:3000"
echo "  Backend API: http://$EXTERNAL_IP:8000"
echo "  API Docs: http://$EXTERNAL_IP:8000/docs"
echo "  MinIO Console: http://$EXTERNAL_IP:9001"
EOF

chmod +x /opt/decision-platform/health-check.sh

print_status "Health check script created at /opt/decision-platform/health-check.sh"
print_status "Run it anytime with: /opt/decision-platform/health-check.sh"

echo ""
print_status "Setup completed! 🎉"
