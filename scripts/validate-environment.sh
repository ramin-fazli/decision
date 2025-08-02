#!/bin/bash

# Decision Platform - Environment Validation Script
# This script helps validate that all required environment variables and secrets are properly configured

set -e

echo "🔍 Decision Platform Environment Validation"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
REQUIRED_COUNT=0
OPTIONAL_COUNT=0
MISSING_REQUIRED=0
MISSING_OPTIONAL=0

# Function to check required environment variable
check_required() {
    local var_name=$1
    local description=$2
    
    REQUIRED_COUNT=$((REQUIRED_COUNT + 1))
    
    if [ -n "${!var_name}" ]; then
        echo -e "  ✅ ${GREEN}$var_name${NC}: $description"
    else
        echo -e "  ❌ ${RED}$var_name${NC}: $description (MISSING)"
        MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
    fi
}

# Function to check optional environment variable
check_optional() {
    local var_name=$1
    local description=$2
    
    OPTIONAL_COUNT=$((OPTIONAL_COUNT + 1))
    
    if [ -n "${!var_name}" ]; then
        echo -e "  ✅ ${GREEN}$var_name${NC}: $description"
    else
        echo -e "  ⚠️  ${YELLOW}$var_name${NC}: $description (Optional)"
        MISSING_OPTIONAL=$((MISSING_OPTIONAL + 1))
    fi
}

# Function to validate format
validate_format() {
    local var_name=$1
    local pattern=$2
    local error_msg=$3
    
    if [ -n "${!var_name}" ]; then
        if [[ ${!var_name} =~ $pattern ]]; then
            echo -e "    ${BLUE}Format: Valid${NC}"
        else
            echo -e "    ${RED}Format: Invalid - $error_msg${NC}"
        fi
    fi
}

echo ""
echo "📋 Required Environment Variables/Secrets:"
echo "----------------------------------------"

# Load .env file if it exists
if [ -f ".env" ]; then
    echo "Loading .env file..."
    source .env
fi

# Essential secrets for GitHub Actions
check_required "GCP_SA_KEY" "Service account key JSON for GCP authentication"
check_required "GCP_PROJECT_ID" "Google Cloud Project ID"
validate_format "GCP_PROJECT_ID" "^[a-z][a-z0-9-]*[a-z0-9]$" "Must be lowercase, start with letter, contain only letters, numbers, and hyphens"

check_required "DB_PASSWORD" "PostgreSQL database password"
validate_format "DB_PASSWORD" ".{8,}" "Should be at least 8 characters long"

check_required "SECRET_KEY" "FastAPI secret key for JWT tokens"
validate_format "SECRET_KEY" ".{32,}" "Should be at least 32 characters long (use: openssl rand -hex 32)"

check_required "MINIO_ACCESS_KEY" "MinIO object storage access key"
check_required "MINIO_SECRET_KEY" "MinIO object storage secret key"
validate_format "MINIO_SECRET_KEY" ".{8,}" "Should be at least 8 characters long"

echo ""
echo "🔧 Optional Cloud Provider Configuration:"
echo "----------------------------------------"

check_optional "AWS_ACCESS_KEY_ID" "AWS access key for cloud services"
check_optional "AWS_SECRET_ACCESS_KEY" "AWS secret key for cloud services"
check_optional "AZURE_SUBSCRIPTION_ID" "Azure subscription ID"
check_optional "SENTRY_DSN" "Sentry DSN for error tracking"

echo ""
echo "⚙️  Application Configuration:"
echo "------------------------------"

check_optional "ENVIRONMENT" "Application environment (development/production)"
check_optional "DEBUG" "Debug mode flag"
check_optional "API_VERSION" "API version"
check_optional "NODE_ENV" "Node.js environment"

# Database configuration
echo ""
echo "🗄️  Database Configuration:"
echo "---------------------------"

check_optional "DB_HOST" "Database host"
check_optional "DB_PORT" "Database port"
check_optional "DB_NAME" "Database name"
check_optional "DB_USER" "Database username"

# Redis configuration
echo ""
echo "🔄 Redis Configuration:"
echo "-----------------------"

check_optional "REDIS_HOST" "Redis host"
check_optional "REDIS_PORT" "Redis port"
check_optional "REDIS_DB" "Redis database number"

echo ""
echo "🌐 Network Configuration:"
echo "-------------------------"

check_optional "ALLOWED_ORIGINS" "Allowed CORS origins"
check_optional "ALLOWED_HOSTS" "Allowed hosts"
check_optional "API_RATE_LIMIT" "API rate limit"

echo ""
echo "📁 File and Storage Configuration:"
echo "----------------------------------"

check_optional "MAX_UPLOAD_SIZE" "Maximum file upload size"
check_optional "ALLOWED_FILE_TYPES" "Allowed file types for upload"
check_optional "UPLOAD_PATH" "File upload path"

echo ""
echo "🧠 ML/AI Configuration:"
echo "-----------------------"

check_optional "ML_MODEL_PATH" "ML model storage path"
check_optional "ML_FEATURE_STORE_PATH" "Feature store path"
check_optional "ML_EXPERIMENT_TRACKING" "Enable ML experiment tracking"

echo ""
echo "📊 Summary:"
echo "----------"

echo -e "Required variables: ${BLUE}$REQUIRED_COUNT${NC} total"
if [ $MISSING_REQUIRED -eq 0 ]; then
    echo -e "✅ All required variables are configured"
else
    echo -e "❌ ${RED}$MISSING_REQUIRED${NC} required variables are missing"
fi

echo -e "Optional variables: ${BLUE}$OPTIONAL_COUNT${NC} total"
echo -e "⚠️  ${YELLOW}$MISSING_OPTIONAL${NC} optional variables are not configured"

echo ""
if [ $MISSING_REQUIRED -eq 0 ]; then
    echo -e "${GREEN}🎉 Environment validation passed!${NC}"
    echo "Your environment is ready for deployment."
else
    echo -e "${RED}❌ Environment validation failed!${NC}"
    echo "Please configure the missing required variables before deployment."
    echo ""
    echo "📝 Next steps:"
    echo "1. Set missing environment variables in your .env file"
    echo "2. Configure missing secrets in GitHub repository settings"
    echo "3. Run this validation script again"
    echo "4. Proceed with deployment once all required variables are set"
    exit 1
fi

echo ""
echo "🔗 Useful commands:"
echo "------------------"
echo "Generate SECRET_KEY: openssl rand -hex 32"
echo "Generate secure password: openssl rand -base64 32"
echo "Check GitHub secrets: Go to repository Settings > Secrets and variables > Actions"
echo "Test deployment: Push to main branch or trigger workflow manually"

echo ""
echo "📚 Documentation:"
echo "-----------------"
echo "Deployment guide: docs/DEPLOYMENT_GCP.md"
echo "Environment setup: .env.example"
echo "GitHub workflow: .github/workflows/deploy-to-gcp-vm.yml"
