#!/bin/bash
# Optimized Docker Setup for Large ML Images (15GB+)
# Run this script on your GCP VM before deployment

set -e

echo "🚀 Optimizing VM for large Docker images..."

# === SYSTEM OPTIMIZATION ===
echo "⚡ Optimizing system settings..."

# Network optimizations for large downloads
sudo tee -a /etc/sysctl.conf << EOF
# Network optimizations for large Docker image downloads
net.core.rmem_default = 262144
net.core.rmem_max = 33554432
net.core.wmem_default = 262144  
net.core.wmem_max = 33554432
net.ipv4.tcp_rmem = 4096 131072 33554432
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_mtu_probing = 1
EOF

sudo sysctl -p

# File descriptor limits
sudo tee -a /etc/security/limits.conf << EOF
* soft nofile 65536
* hard nofile 65536
root soft nofile 65536
root hard nofile 65536
EOF

# === DOCKER DISK SETUP ===
echo "💾 Setting up disk for Docker..."

# Stop Docker
sudo systemctl stop docker 2>/dev/null || true

# Check for secondary disk and set it up
if lsblk | grep -q "sdb" && ! mount | grep -q "/var/lib/docker"; then
    echo "📀 Setting up secondary disk for Docker..."
    
    # Create partition
    if ! lsblk | grep -q "sdb1"; then
        echo "Creating partition..."
        echo -e "n\np\n1\n\n\nw" | sudo fdisk /dev/sdb
        sleep 2
    fi
    
    # Format with optimized settings for large files
    if ! blkid /dev/sdb1 | grep -q "ext4"; then
        echo "Formatting with optimized settings..."
        sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0 -O ^has_journal /dev/sdb1
    fi
    
    # Mount with optimized flags
    sudo mkdir -p /mnt/docker-data
    sudo mount -o noatime,nodiratime,data=writeback /dev/sdb1 /mnt/docker-data
    
    # Move Docker data
    if [ -d "/var/lib/docker" ] && [ "$(ls -A /var/lib/docker 2>/dev/null)" ]; then
        sudo cp -a /var/lib/docker/* /mnt/docker-data/
        sudo mv /var/lib/docker /var/lib/docker.backup
    fi
    
    sudo mkdir -p /var/lib/docker
    sudo mount --bind /mnt/docker-data /var/lib/docker
    
    # Permanent mounts with optimized flags
    echo "/dev/sdb1 /mnt/docker-data ext4 noatime,nodiratime,data=writeback,defaults 0 2" | sudo tee -a /etc/fstab
    echo "/mnt/docker-data /var/lib/docker none bind 0 0" | sudo tee -a /etc/fstab
    
    sudo chown -R root:root /mnt/docker-data
    sudo chmod 755 /mnt/docker-data
fi

# === DOCKER OPTIMIZATION ===
echo "🐳 Configuring Docker for large images..."

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ],
    "max-concurrent-downloads": 10,
    "max-concurrent-uploads": 5,
    "max-download-attempts": 3,
    "live-restore": true,
    "userland-proxy": false,
    "experimental": false,
    "registry-mirrors": [],
    "insecure-registries": [],
    "default-network-opts": {
        "bridge": {
            "com.docker.network.driver.mtu": "1500"
        }
    }
}
EOF

# === DOCKER SERVICE OPTIMIZATION ===
echo "🔧 Optimizing Docker service..."

# Create optimized Docker service override
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --max-concurrent-downloads=10 --max-concurrent-uploads=5
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
TasksMax=infinity
EOF

# Reload and start Docker
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker

# === VERIFY SETUP ===
echo "✅ Verifying setup..."

echo "📊 Disk space:"
df -h /var/lib/docker 2>/dev/null || df -h /

echo "🐳 Docker info:"
docker --version
docker info | head -10

echo "🌐 Network settings:"
sysctl net.ipv4.tcp_congestion_control

echo "🎉 Setup completed!"
echo ""
echo "💡 Tips for faster downloads:"
echo "   - Your VM should now download 15GB images in 3-5 minutes"
echo "   - If still slow, check if you're in the same region as your registry"
echo "   - Consider using a VM with more CPU cores for faster parallel downloads"
echo ""
echo "🚀 Ready for deployment!"
