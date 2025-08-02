# Decision Platform - GCP Deployment Guide

This guide explains how to deploy the Decision Platform to Google Cloud Platform (GCP) using the automated GitHub Actions workflow.

## Prerequisites

1. **GCP Project**: You need an active Google Cloud Platform project
2. **GCP VM Instance**: A VM instance where the application will be deployed
3. **GitHub Repository**: Fork or clone this repository to your GitHub account
4. **Docker**: The deployment uses containerized applications

## Required GitHub Secrets

Before running the deployment workflow, you need to configure the following secrets in your GitHub repository settings (`Settings > Secrets and variables > Actions`):

### Essential Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `GCP_SA_KEY` | Service account key JSON for GCP authentication | `{"type": "service_account", ...}` |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | `my-decision-platform-project` |
| `DB_PASSWORD` | PostgreSQL database password | `secure_database_password123` |
| `SECRET_KEY` | FastAPI secret key for JWT tokens | Generate with: `openssl rand -hex 32` |
| `MINIO_ACCESS_KEY` | MinIO object storage access key | `minioadmin` or custom key |
| `MINIO_SECRET_KEY` | MinIO object storage secret key | `minioadmin` or custom secret |

### Optional Cloud Provider Secrets

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `AWS_ACCESS_KEY_ID` | AWS access key for cloud services | Optional |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for cloud services | Optional |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | Optional |
| `SENTRY_DSN` | Sentry DSN for error tracking | Optional |

## GCP Setup Instructions

### 1. Create a GCP Service Account

```bash
# Set your project ID
export PROJECT_ID="your-project-id"

# Create a service account
gcloud iam service-accounts create decision-platform-deploy \
    --description="Service account for Decision Platform deployment" \
    --display-name="Decision Platform Deployer"

# Grant necessary permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:decision-platform-deploy@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:decision-platform-deploy@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:decision-platform-deploy@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Create and download the service account key
gcloud iam service-accounts keys create decision-platform-sa-key.json \
    --iam-account=decision-platform-deploy@$PROJECT_ID.iam.gserviceaccount.com
```

### 2. Create a GCP VM Instance

```bash
# Create a VM instance for deployment
gcloud compute instances create decision-platform-vm \
    --zone=us-east4-c \
    --machine-type=e2-standard-4 \
    --network-interface=network-tier=PREMIUM,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --tags=decision-platform \
    --create-disk=auto-delete=yes,boot=yes,device-name=decision-platform-vm,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240319,mode=rw,size=50,type=projects/$PROJECT_ID/zones/us-east4-c/diskTypes/pd-standard \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=environment=production,application=decision-platform \
    --reservation-affinity=any
```

### 3. Install Docker on the VM

```bash
# SSH into the VM
gcloud compute ssh decision-platform-vm --zone=us-east4-c

# Install Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER

# Install Google Cloud CLI (if not already installed)
sudo apt-get install -y google-cloud-cli

# Exit and reconnect to refresh group membership
exit
```

## Deployment Configuration

### Update Workflow Variables

In the `.github/workflows/deploy-to-gcp-vm.yml` file, update these environment variables to match your setup:

```yaml
env:
  GAR_LOCATION: us-east4                    # Your preferred region
  GAR_REPOSITORY: decision-platform        # Repository name in Artifact Registry
  BACKEND_IMAGE_NAME: decision-backend     # Backend image name
  FRONTEND_IMAGE_NAME: decision-frontend   # Frontend image name
  VM_ZONE: us-east4-c                      # Your VM zone
  VM_NAME: decision-platform-vm            # Your VM name
  SERVICE_NAME: decision-platform          # Service name for containers
```

### Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to `Settings > Secrets and variables > Actions`
3. Click `New repository secret`
4. Add each required secret from the table above

For the `GCP_SA_KEY` secret, copy the entire contents of the `decision-platform-sa-key.json` file.

## Running the Deployment

### Automatic Deployment

The workflow automatically triggers on:
- Push to the `main` branch
- Manual trigger via GitHub Actions UI

### Manual Deployment

1. Go to your GitHub repository
2. Navigate to `Actions` tab
3. Select `Deploy Decision Platform to GCP VM` workflow
4. Click `Run workflow`
5. Optionally check `Force deployment even if no changes`
6. Click `Run workflow`

## Deployment Process

The workflow performs the following steps:

1. **Build Backend**: Builds and pushes the FastAPI backend Docker image
2. **Build Frontend**: Builds and pushes the Next.js frontend Docker image
3. **Security Scan**: Performs security scanning with Trivy
4. **Deploy to VM**: 
   - Configures firewall rules
   - Deploys containers using docker-compose
   - Sets up PostgreSQL, Redis, MinIO, and Nginx
   - Performs health checks
5. **Cleanup**: Removes old Docker images from Artifact Registry

## Accessing the Application

After successful deployment, the application will be available at:

- **Frontend**: `http://VM_EXTERNAL_IP:3000`
- **Backend API**: `http://VM_EXTERNAL_IP:8000`
- **API Documentation**: `http://VM_EXTERNAL_IP:8000/docs`
- **MinIO Console**: `http://VM_EXTERNAL_IP:9001`

You can find your VM's external IP with:
```bash
gcloud compute instances describe decision-platform-vm \
  --zone=us-east4-c \
  --format="value(networkInterfaces[0].accessConfigs[0].natIP)"
```

## Monitoring and Troubleshooting

### View Deployment Logs

1. Go to GitHub Actions tab in your repository
2. Click on the latest workflow run
3. Expand the job steps to view detailed logs

### SSH into VM for Debugging

```bash
# SSH into the VM
gcloud compute ssh decision-platform-vm --zone=us-east4-c

# Check container status
docker-compose -f /opt/decision-platform/docker-compose.prod.yml ps

# View container logs
docker-compose -f /opt/decision-platform/docker-compose.prod.yml logs [service-name]

# View system logs
sudo journalctl -u docker
```

### Common Issues

1. **Port Conflicts**: Make sure ports 80, 443, 3000, 8000 are not in use
2. **Docker Permissions**: Verify user is in docker group
3. **Firewall Rules**: Ensure GCP firewall rules allow traffic on required ports
4. **VM Resources**: Check if VM has sufficient CPU and memory
5. **Environment Variables**: Verify all required secrets are configured

## Security Considerations

1. **Firewall Rules**: The workflow creates firewall rules for required ports
2. **HTTPS**: Consider setting up SSL certificates for production
3. **Secrets Management**: Never commit secrets to the repository
4. **VM Access**: Limit SSH access to the VM
5. **Regular Updates**: Keep Docker images and VM OS updated

## Customization

### Environment Variables

You can customize the deployment by modifying the environment variables in the workflow file or by updating the `.env.example` file.

### Docker Compose Configuration

The production `docker-compose.prod.yml` is generated during deployment. You can modify the template in the workflow to customize service configurations.

### Resource Allocation

Adjust VM size and Docker resource limits based on your application needs:

```bash
# Scale up VM
gcloud compute instances set-machine-type decision-platform-vm \
  --machine-type=e2-standard-8 \
  --zone=us-east4-c
```

## Support

For issues and questions:
1. Check the GitHub Issues page
2. Review the deployment logs in GitHub Actions
3. Verify all prerequisites are met
4. Ensure all secrets are correctly configured

## License

This deployment configuration is part of the Decision Platform project. See the main LICENSE file for details.
