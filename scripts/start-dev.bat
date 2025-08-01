@echo off
REM Quick development server startup script for Windows
REM This script starts both backend and frontend servers

echo 🚀 Starting Decision Platform Development Servers...

REM Check if we're in the right directory
if not exist docker-compose.yml (
    echo ❌ Please run this script from the project root directory
    pause
    exit /b 1
)

REM Start background services first
echo 🐳 Starting background services (PostgreSQL, Redis)...
docker-compose up -d postgres redis

REM Wait a moment for services to start
echo ⏳ Waiting for services to initialize...
timeout /t 5 /nobreak >nul

REM Check if backend virtual environment exists
if not exist backend\venv (
    echo ❌ Backend virtual environment not found. Run setup first.
    pause
    exit /b 1
)

REM Check if frontend dependencies exist
if not exist frontend\node_modules (
    echo ❌ Frontend dependencies not found. Run setup first.
    pause
    exit /b 1
)

echo.
echo 🎉 Starting development servers...
echo.
echo 📡 Services will be available at:
echo   • Backend API: http://localhost:8000
echo   • API Documentation: http://localhost:8000/docs
echo   • Frontend: http://localhost:3000
echo   • PostgreSQL: localhost:5432
echo   • Redis: localhost:6379
echo.
echo 📋 Press Ctrl+C in each window to stop the servers
echo ────────────────────────────────────────────────────────────
echo.

REM Start backend server in new window
echo 🐍 Starting backend server...
start "Decision Backend" cmd /k "cd backend && venv\Scripts\activate && uvicorn api.main:app --reload --host 0.0.0.0 --port 8000"

REM Wait a moment
timeout /t 2 /nobreak >nul

REM Start frontend server in new window
echo ⚛️ Starting frontend server...
start "Decision Frontend" cmd /k "cd frontend && npm run dev"

echo.
echo ✅ Development servers started in separate windows!
echo.
echo 📊 You can now:
echo   • Visit http://localhost:3000 to see the application
echo   • Visit http://localhost:8000/docs to see the API documentation
echo   • Check the separate terminal windows for logs
echo.
pause
