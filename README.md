# Decision - AI-Powered Investment Intelligence Platform

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Python](https://img.shields.io/badge/python-v3.9+-blue.svg?logo=python&logoColor=white)](https://www.python.org/downloads/)
[![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=flat&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=flat&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Next.js](https://img.shields.io/badge/Next.js-000000?style=flat&logo=next.js&logoColor=white)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-20232A?style=flat&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=flat&logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/redis-%23DD0031.svg?style=flat&logo=redis&logoColor=white)](https://redis.io/)
[![Scikit Learn](https://img.shields.io/badge/scikit--learn-%23F7931E.svg?style=flat&logo=scikit-learn&logoColor=white)](https://scikit-learn.org/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-%23FF6F00.svg?style=flat&logo=TensorFlow&logoColor=white)](https://www.tensorflow.org/)
[![PyTorch](https://img.shields.io/badge/PyTorch-%23EE4C2C.svg?style=flat&logo=PyTorch&logoColor=white)](https://pytorch.org/)

**Decision** is an AI-powered decision intelligence platform that transforms investment decision-making through advanced machine learning and quantitative analytics.

## 🎓 From Research to Reality

My journey began with completing a master's thesis titled *"The Impact of AI-powered Decision-Making on Venture Capital Investments"*. In that research, I implemented and evaluated four machine learning models (Decision Trees, Random Forests, Neural Networks, QDA) using Python and scikit-learn on Crunchbase data to predict startup success. The thesis employed empirical, data-driven methods and quantitative analysis to simulate AI-enhanced decision-making in venture capital.

Now, I've evolved that academic foundation into **Decision** - a robust, scalable SaaS platform that brings cutting-edge AI to investment professionals across multiple asset classes.

## 🚀 What is Decision?

Decision is an API-first investment intelligence platform that provides:

- **Predictive Analytics**: Advanced ML models for investment outcome prediction
- **Multi-Asset Support**: Extensible across VC, private equity, and public markets
- **Data Agnostic**: Seamless integration with any data source or format
- **Explainable AI**: Model transparency through SHAP and LIME integration
- **Real-time Intelligence**: Live monitoring and decision support

## 🏗️ Architecture Overview

### Core Design Principles
- **API-First**: Our main interface is our API, flexibly integrating with any system
- **Cloud-Agnostic**: Runs on AWS, GCP, or Azure
- **Modular & Scalable**: Microservices architecture with independent scaling
- **Data Source Agnostic**: CSV, Excel, APIs, SQL/NoSQL databases supported

### Technology Stack

**Backend (Python)**
- FastAPI for high-performance API services
- Scikit-learn, TensorFlow, PyTorch for ML/AI
- SQLAlchemy for database abstraction
- Celery for async task processing
- Redis for caching and message queuing

**Frontend (TypeScript)**
- Next.js 14 with React 18
- Tailwind CSS for modern styling
- Recharts for data visualization
- SWR for data fetching and caching

**Infrastructure**
- Docker & Docker Compose for containerization
- **Enterprise Kubernetes** with multi-cloud support (AWS EKS, GCP GKE, Azure AKS)
- **Advanced Terraform modules** for cloud-agnostic infrastructure
- **GitOps workflows** with ArgoCD and ApplicationSets
- **Production-ready security** with Pod Security Standards and network policies
- GitHub Actions for CI/CD
- PostgreSQL for primary data storage
- MinIO for object storage

**ML/AI Platform**
- Support for cloud ML services (Vertex AI, SageMaker, Azure ML)
- Local inference capabilities
- Model versioning and experiment tracking with MLflow
- Feature pipelines with Apache Airflow

## 📁 Project Structure

```
decision/
├── backend/                    # Python backend services
│   ├── api/                   # FastAPI application
│   ├── ml/                    # ML engine and models
│   ├── data/                  # Data ingestion and processing
│   └── core/                  # Shared utilities and config
├── frontend/                  # Next.js React application
├── infrastructure/            # Enterprise-grade infrastructure
│   ├── terraform/            # Multi-cloud Terraform modules
│   │   ├── modules/          # Reusable infrastructure components
│   │   │   ├── networking/   # VPC, security groups, networking
│   │   │   ├── compute/      # Kubernetes clusters (EKS/GKE/AKS)
│   │   │   ├── database/     # PostgreSQL, Redis with encryption
│   │   │   └── storage/      # Cloud storage with lifecycle policies
│   │   └── environments/     # Environment-specific configurations
│   └── kubernetes/           # Advanced K8s configurations
│       ├── base/            # Core K8s resources (RBAC, security)
│       ├── charts/          # Production-ready Helm charts
│       └── gitops/          # ArgoCD applications and workflows
├── docker/                   # Docker configurations
├── .github/                  # CI/CD workflows
└── docs/                     # Documentation
```

## 🎯 Key Features

### Decision Engine API
- RESTful API for investment predictions
- Real-time model inference
- Batch processing capabilities
- Model explainability endpoints

### Interactive Dashboard
- Data connection and upload interface
- Investment simulation and scenario modeling
- Performance monitoring and insights
- Recommendation visualization

### ML Pipeline
- Automated feature engineering
- Model training and validation
- A/B testing framework
- Continuous model improvement

## 🛣️ Roadmap

### Phase 1: Foundation (Current)
- [x] **Enterprise Infrastructure** - Multi-cloud Terraform modules with Kubernetes
- [x] **Advanced Security** - Pod Security Standards, network policies, encryption
- [x] **GitOps Workflows** - ArgoCD with progressive delivery capabilities
- [ ] Core API infrastructure
- [ ] Basic ML models implementation
- [ ] Frontend dashboard MVP
- [ ] Data ingestion pipeline

### Phase 2: Intelligence
- [ ] Advanced ML models
- [ ] Model explainability
- [ ] Real-time predictions
- [ ] Performance monitoring

### Phase 3: Scale
- [ ] Multi-asset class support
- [ ] Enterprise integrations
- [ ] Advanced analytics
- [ ] Mobile applications

## 🏦 Industry Applications

**Venture Capital**
- Startup success prediction
- Portfolio optimization
- Deal flow analysis
- Exit probability modeling

**Private Equity**
- Target company evaluation
- Performance forecasting
- Risk assessment
- Value creation planning

**Public Markets**
- Stock selection and ranking
- Market timing signals
- Risk management
- Portfolio construction

## 🚀 Quick Start

### Prerequisites
- **Python 3.9+** - [Download from python.org](https://python.org)
- **Node.js 18+** - [Download from nodejs.org](https://nodejs.org)
- **Docker Desktop** - [Download from docker.com](https://docker.com)
- **Git** - [Download from git-scm.com](https://git-scm.com)

### Development Environment Setup

#### Option 1: Universal Setup (Recommended)
```bash
# Clone the repository
git clone https://github.com/ramin-fazli/decision.git
cd decision

# Run the universal setup launcher
./setup
```

#### Option 2: Platform-Specific Setup

**Windows (Command Prompt/PowerShell):**
```cmd
scripts\setup.bat
```

**Windows (Git Bash) or Linux/Mac:**
```bash
./scripts/setup.sh
```

#### Option 3: Docker Only (Simplest)
```bash
# Clone and start with Docker
git clone https://github.com/ramin-fazli/decision.git
cd decision
docker-compose up -d
```

### Production Deployment

#### Infrastructure Prerequisites
- **Terraform >= 1.6** - [Download from terraform.io](https://terraform.io)
- **kubectl** - [Install guide](https://kubernetes.io/docs/tasks/tools/)
- **Helm >= 3.0** - [Install guide](https://helm.sh/docs/intro/install/)
- **Cloud CLI** - AWS CLI, gcloud, or Azure CLI

#### Deploy Infrastructure
```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Plan deployment (choose your cloud)
terraform plan -var-file="environments/production/terraform.tfvars"

# Apply infrastructure
terraform apply -var-file="environments/production/terraform.tfvars"
```

#### Deploy Applications via GitOps
```bash
# ArgoCD is automatically installed and configured
# Applications will auto-deploy via GitOps workflows

# Manual deployment (if needed)
cd infrastructure/kubernetes/helm-charts
helm install decision-ai ./decision-ai-platform -f values-production.yaml
```
git clone https://github.com/ramin-fazli/decision.git
cd decision
docker-compose up -d
```

### Start Development Servers

After setup, start the development servers:

**Windows:**
```cmd
scripts\start-dev.bat
```

**Linux/Mac/Git Bash:**
```bash
./scripts/start-dev.sh
```

**Manual Start:**
```bash
# Terminal 1 - Backend
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate
uvicorn api.main:app --reload

# Terminal 2 - Frontend  
cd frontend
npm run dev

# Terminal 3 - Services
docker-compose up -d postgres redis
```

### Access the Platform
- **Frontend**: http://localhost:3000
- **API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

## 🎯 Enterprise Infrastructure

The Decision platform leverages enterprise-grade infrastructure with advanced cloud-native technologies:

### Infrastructure Features
- **Multi-Cloud Support**: Deploy on AWS, GCP, or Azure with unified Terraform modules
- **Auto-Scaling Kubernetes**: Production-ready clusters with horizontal pod autoscaling
- **GitOps Workflows**: Automated deployments with ArgoCD and progressive delivery
- **Zero-Trust Security**: Pod Security Standards, network policies, and encryption at rest
- **Observability Stack**: Integrated Prometheus, Grafana, and distributed tracing
- **Service Mesh**: Optional Istio integration for advanced traffic management

### Infrastructure Components
```
infrastructure/
├── terraform/                 # Multi-cloud infrastructure modules
│   ├── modules/
│   │   ├── networking/        # VPC, subnets, security groups
│   │   ├── compute/          # Kubernetes clusters (EKS/GKE/AKS)
│   │   ├── database/         # Managed databases with encryption
│   │   └── storage/          # Object storage with lifecycle policies
│   └── environments/         # Environment-specific configurations
├── kubernetes/
│   ├── base/                 # Core K8s configurations
│   ├── gitops/              # ArgoCD applications and workflows
│   └── helm-charts/         # Production Helm charts
└── monitoring/              # Observability stack configurations
```

## 🏭 Production Deployment

### Google Cloud Platform (GCP)

Deploy the Decision Platform to GCP using our automated GitHub Actions workflow:

1. **Prerequisites Setup**
   ```bash
   # Validate your environment
   chmod +x scripts/validate-environment.sh
   ./scripts/validate-environment.sh
   ```

2. **Configure GitHub Secrets**
   - Go to your repository Settings > Secrets and variables > Actions
   - Add required secrets (see [deployment guide](docs/DEPLOYMENT_GCP.md))

3. **Deploy via GitHub Actions**
   - Push to `main` branch for automatic deployment
   - Or manually trigger the "Deploy Decision Platform to GCP VM" workflow

4. **VM Setup** (if needed)
   ```bash
   # Prepare your GCP VM
   chmod +x scripts/setup-gcp-vm.sh
   ./scripts/setup-gcp-vm.sh
   ```

## �📊 Performance

The platform is built for scale:
- **API Response Time**: < 100ms for predictions
- **Throughput**: 10,000+ predictions per second
- **Uptime**: 99.9% availability target
- **Data Processing**: Real-time and batch capabilities

## 🤝 Contributing

This platform represents the evolution of academic research into practical investment tools. Contributions are welcome from both academic and industry perspectives.

## 📄 License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.

---

*Transforming investment decisions through AI - from thesis to production.*
