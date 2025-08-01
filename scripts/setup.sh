#!/bin/bash

# Decision Platform Setup Script
# This script sets up the local development environment

set -e

echo "🚀 Setting up Decision Platform..."

# Check if required tools are installed
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed. Please install it first."
        exit 1
    fi
}

echo "📋 Checking dependencies..."
echo "🔍 Debug info: OSTYPE=$OSTYPE"
echo "🔍 Debug info: PWD=$PWD"

check_dependency "docker"
check_dependency "docker-compose"

# Check for Python (Windows uses 'python', Unix uses 'python3')
echo "🔍 Checking for Python..."

# Function to test if Python command actually works
test_python_command() {
    local cmd=$1
    if $cmd --version >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Try different Python commands in order of preference
if command -v python &> /dev/null && test_python_command python; then
    PYTHON_CMD="python"
    echo "✅ Found working python: $(which python)"
    python --version
elif command -v python3 &> /dev/null && test_python_command python3; then
    PYTHON_CMD="python3"
    echo "✅ Found working python3: $(which python3)"
    python3 --version
elif command -v py &> /dev/null && test_python_command py; then
    PYTHON_CMD="py"
    echo "✅ Found working py launcher: $(which py)"
    py --version
else
    echo "❌ No working Python installation found."
    echo "🔧 Solutions:"
    echo "   1. Install Python from https://python.org (recommended)"
    echo "   2. Or disable Windows Store Python stub:"
    echo "      Settings > Apps > App execution aliases > Turn off Python"
    echo "   3. Or use Windows Command Prompt: scripts\\setup.bat"
    exit 1
fi

check_dependency "node"
check_dependency "npm"

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating environment file..."
    cp .env.example .env
    echo "✅ Created .env file. Please review and update the configuration."
fi

# Setup backend
echo "🐍 Setting up backend..."
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    $PYTHON_CMD -m venv venv
    echo "✅ Created Python virtual environment"
fi

# Activate virtual environment and install dependencies
# Windows/Git Bash activation
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi
pip install --upgrade pip
pip install -r requirements.txt
echo "✅ Installed Python dependencies"

# Run database migrations (if applicable)
# alembic upgrade head

cd ..

# Setup frontend
echo "⚛️ Setting up frontend..."
cd frontend

# Install Node.js dependencies
npm install
echo "✅ Installed Node.js dependencies"

cd ..

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p backend/uploads
mkdir -p backend/models
mkdir -p backend/features
mkdir -p data/samples

# Download sample data (optional)
echo "📊 Setting up sample data..."
if [ ! -f "data/samples/sample_startups.csv" ]; then
    echo "Creating sample startup data..."
    cat > data/samples/sample_startups.csv << EOF
name,category_code,funding_total_usd,founded_at,country_code,state_code,employee_count,status
TechCorp,software,1000000,2015-01-15,USA,CA,50,operating
DataStart,analytics,500000,2018-03-22,USA,NY,25,operating
AIInnovate,artificial-intelligence,2000000,2017-06-10,USA,CA,75,acquired
CloudSys,cloud,750000,2019-11-05,USA,WA,30,operating
FinTechPro,fintech,1500000,2016-09-18,USA,NY,60,closed
EOF
    echo "✅ Created sample data file"
fi

# Start services
echo "🐳 Starting services..."
docker-compose up -d postgres redis

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Run database initialization
echo "🗄️ Initializing database..."
cd backend
# Activate virtual environment again for database initialization
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi
# python -m alembic upgrade head
# python scripts/init_data.py  # If you have an initialization script
cd ..

echo "✅ Setup complete!"
echo ""
echo "🎉 Decision Platform is ready!"
echo ""
echo "📚 Next steps:"
echo "1. Review and update .env file with your configuration"
echo "2. Start the development servers:"
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "   Backend:  cd backend && source venv/Scripts/activate && uvicorn api.main:app --reload"
else
    echo "   Backend:  cd backend && source venv/bin/activate && uvicorn api.main:app --reload"
fi
echo "   Frontend: cd frontend && npm run dev"
echo "3. Visit http://localhost:3000 to access the platform"
echo "4. API documentation: http://localhost:8000/docs"
echo ""
echo "🔧 Useful commands:"
echo "   Start all services: docker-compose up -d"
echo "   Stop all services: docker-compose down"
echo "   View logs: docker-compose logs -f"
echo "   Reset database: docker-compose down -v && docker-compose up -d"
