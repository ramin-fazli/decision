@echo off
REM Decision Platform Setup Script for Windows
REM This script sets up the local development environment on Windows

echo 🚀 Setting up Decision Platform...

REM Check if required tools are installed
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)
echo ✅ Found Docker

where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)
echo ✅ Found Docker Compose

REM Check for Python
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Python is not installed. Please install Python from python.org first.
    pause
    exit /b 1
)
echo ✅ Found Python

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed. Please install Node.js first.
    pause
    exit /b 1
)
echo ✅ Found Node.js

where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ npm is not installed. Please install npm first.
    pause
    exit /b 1
)
echo ✅ Found npm

REM Create environment file if it doesn't exist
if not exist .env (
    echo 📝 Creating environment file...
    copy .env.example .env
    echo ✅ Created .env file. Please review and update the configuration.
)

REM Setup backend
echo 🐍 Setting up backend...
cd backend

REM Create virtual environment
if not exist venv (
    python -m venv venv
    echo ✅ Created Python virtual environment
)

REM Activate virtual environment and install dependencies
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt
echo ✅ Installed Python dependencies

cd ..

REM Setup frontend
echo ⚛️ Setting up frontend...
cd frontend

REM Install Node.js dependencies
npm install
echo ✅ Installed Node.js dependencies

cd ..

REM Create necessary directories
echo 📁 Creating directories...
if not exist backend\uploads mkdir backend\uploads
if not exist backend\models mkdir backend\models
if not exist backend\features mkdir backend\features
if not exist data\samples mkdir data\samples

REM Create sample data
echo 📊 Setting up sample data...
if not exist data\samples\sample_startups.csv (
    echo Creating sample startup data...
    (
        echo name,category_code,funding_total_usd,founded_at,country_code,state_code,employee_count,status
        echo TechCorp,software,1000000,2015-01-15,USA,CA,50,operating
        echo DataStart,analytics,500000,2018-03-22,USA,NY,25,operating
        echo AIInnovate,artificial-intelligence,2000000,2017-06-10,USA,CA,75,acquired
        echo CloudSys,cloud,750000,2019-11-05,USA,WA,30,operating
        echo FinTechPro,fintech,1500000,2016-09-18,USA,NY,60,closed
    ) > data\samples\sample_startups.csv
    echo ✅ Created sample data file
)

REM Start services
echo 🐳 Starting services...
docker-compose up -d postgres redis

REM Wait for services to be ready
echo ⏳ Waiting for services to be ready...
timeout /t 10 /nobreak >nul

REM Run database initialization
echo 🗄️ Initializing database...
cd backend
call venv\Scripts\activate.bat
REM python -m alembic upgrade head
REM python scripts\init_data.py
cd ..

echo ✅ Setup complete!
echo.
echo 🎉 Decision Platform is ready!
echo.
echo 📚 Next steps:
echo 1. Review and update .env file with your configuration
echo 2. Start the development servers:
echo    Backend:  cd backend ^&^& venv\Scripts\activate ^&^& uvicorn api.main:app --reload
echo    Frontend: cd frontend ^&^& npm run dev
echo 3. Visit http://localhost:3000 to access the platform
echo 4. API documentation: http://localhost:8000/docs
echo.
echo 🔧 Useful commands:
echo    Start all services: docker-compose up -d
echo    Stop all services: docker-compose down
echo    View logs: docker-compose logs -f
echo    Reset database: docker-compose down -v ^&^& docker-compose up -d
echo.
pause
