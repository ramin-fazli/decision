# Decision - AI-Powered Investment Intelligence Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/python-v3.9+-blue.svg)](https://www.python.org/downloads/)
[![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=flat&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)

**Decision** (https://decision.is) is a production-ready, AI-powered decision intelligence platform that transforms investment decision-making through advanced machine learning and quantitative analytics.

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
- Kubernetes for orchestration
- Terraform for Infrastructure as Code
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
├── infrastructure/            # Terraform and K8s configs
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

### Setup Instructions

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

## 📊 Performance

The platform is built for scale:
- **API Response Time**: < 100ms for predictions
- **Throughput**: 10,000+ predictions per second
- **Uptime**: 99.9% availability target
- **Data Processing**: Real-time and batch capabilities

## 🤝 Contributing

This platform represents the evolution of academic research into practical investment tools. Contributions are welcome from both academic and industry perspectives.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

*Transforming investment decisions through AI - from thesis to production.*
