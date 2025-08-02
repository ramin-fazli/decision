# VM Disk Setup for Large Docker Images

If you're experiencing timeout errors during Docker image pulls due to large ML/AI images, follow these steps to configure your VM properly.

## Quick Setup Script

SSH into your VM and run this script to set up Docker on the additional disk:

```bash
#!/bin/bash
# Run this script on your GCP VM to set up Docker disk space

echo "🔧 Setting up Docker disk space for large images..."

# Stop Docker
sudo systemctl stop docker 2>/dev/null || true

# Check if secondary disk exists
if lsblk | grep -q "sdb"; then
    echo "📀 Secondary disk found: /dev/sdb"
    
    # Create partition if needed
    if ! lsblk | grep -q "sdb1"; then
        echo "📦 Creating partition on /dev/sdb..."
        echo -e "n\np\n1\n\n\nw" | sudo fdisk /dev/sdb
        sleep 2
    fi
    
    # Format if needed
    if ! blkid /dev/sdb1 | grep -q "ext4"; then
        echo "📝 Formatting /dev/sdb1..."
        sudo mkfs.ext4 -F /dev/sdb1
    fi
    
    # Create mount point
    sudo mkdir -p /mnt/docker-data
    
    # Mount the disk
    sudo mount /dev/sdb1 /mnt/docker-data
    
    # Move existing Docker data if any
    if [ -d "/var/lib/docker" ] && [ "$(ls -A /var/lib/docker 2>/dev/null)" ]; then
        echo "📦 Moving existing Docker data..."
        sudo cp -a /var/lib/docker/* /mnt/docker-data/ 2>/dev/null || true
        sudo mv /var/lib/docker /var/lib/docker.backup
    fi
    
    # Create Docker directory and bind mount
    sudo mkdir -p /var/lib/docker
    sudo mount --bind /mnt/docker-data /var/lib/docker
    
    # Make mounts permanent
    if ! grep -q "/mnt/docker-data" /etc/fstab; then
        echo "/dev/sdb1 /mnt/docker-data ext4 defaults 0 2" | sudo tee -a /etc/fstab
        echo "/mnt/docker-data /var/lib/docker none bind 0 0" | sudo tee -a /etc/fstab
    fi
    
    # Set permissions
    sudo chown -R root:root /mnt/docker-data
    sudo chmod 755 /mnt/docker-data
    
    echo "✅ Docker configured to use secondary disk"
else
    echo "⚠️ No secondary disk found"
    echo "Your VM might need an additional disk attached"
fi

# Configure Docker daemon for large images
sudo mkdir -p /etc/docker
cat << 'DOCKER_CONFIG' | sudo tee /etc/docker/daemon.json
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
    "max-concurrent-downloads": 2,
    "max-concurrent-uploads": 2
}
DOCKER_CONFIG

# Start Docker
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker

# Verify setup
echo "📊 Disk space available for Docker:"
df -h /var/lib/docker 2>/dev/null || df -h /

echo "🐳 Docker info:"
docker info | head -20

echo "✅ Setup completed!"
```

## Manual Steps

If you prefer manual setup:

### 1. Check Available Disks
```bash
sudo lsblk
df -h
```

### 2. Set Up Additional Disk (if you have /dev/sdb)
```bash
# Create partition
sudo fdisk /dev/sdb
# In fdisk: n -> p -> 1 -> [Enter] -> [Enter] -> w

# Format the partition
sudo mkfs.ext4 /dev/sdb1

# Mount for Docker
sudo mkdir -p /mnt/docker-data
sudo mount /dev/sdb1 /mnt/docker-data

# Move Docker data
sudo systemctl stop docker
sudo cp -a /var/lib/docker/* /mnt/docker-data/ 2>/dev/null || true
sudo mv /var/lib/docker /var/lib/docker.backup
sudo mkdir -p /var/lib/docker
sudo mount --bind /mnt/docker-data /var/lib/docker

# Make permanent
echo "/dev/sdb1 /mnt/docker-data ext4 defaults 0 2" | sudo tee -a /etc/fstab
echo "/mnt/docker-data /var/lib/docker none bind 0 0" | sudo tee -a /etc/fstab
```

### 3. Configure Docker for Large Images
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json << EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "max-concurrent-downloads": 2,
    "max-concurrent-uploads": 2
}
EOF

sudo systemctl daemon-reload
sudo systemctl start docker
```

### 4. Verify Setup
```bash
df -h /var/lib/docker
docker info | grep -i "docker root dir"
```

## Alternative: Increase VM Disk Size

If you don't have a secondary disk, you can increase the main disk:

```bash
# Stop the VM first
gcloud compute instances stop decision-platform-vm --zone=us-east4-c

# Resize the disk
gcloud compute disks resize decision-platform-vm \
    --size=50GB \
    --zone=us-east4-c

# Start the VM
gcloud compute instances start decision-platform-vm --zone=us-east4-c

# SSH in and expand the filesystem
gcloud compute ssh decision-platform-vm --zone=us-east4-c
sudo growpart /dev/sda 1
sudo resize2fs /dev/sda1
```

After running these steps, your GitHub Actions deployment should complete successfully without timing out during Docker image pulls.
