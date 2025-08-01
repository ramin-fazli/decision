@echo off
echo Starting Decision Platform Development Servers...
echo.

REM Start backend server
echo Starting FastAPI backend server on port 8000...
start "Decision Backend" cmd /k "cd /d D:\vc-system\decision\backend && D:\vc-system\decision\backend\venv\Scripts\python.exe -m uvicorn api.main:app --reload --host 0.0.0.0 --port 8000"

REM Wait a moment for backend to start
timeout /t 3 /nobreak >nul

REM Start frontend server
echo Starting Next.js frontend server on port 3000...
start "Decision Frontend" cmd /k "cd /d D:\vc-system\decision\frontend && npm run dev"

echo.
echo Both servers are starting...
echo.
echo Backend API: http://localhost:8000
echo Frontend App: http://localhost:3000
echo API Documentation: http://localhost:8000/docs
echo.
echo Press any key to continue...
pause >nul
