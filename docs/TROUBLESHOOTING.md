# Setup Troubleshooting Guide

## Common Issues and Solutions

### 1. Python Not Found (Windows)

**Error**: `Python was not found; run without arguments to install from the Microsoft Store`

**Solutions**:
- **Option A**: Use the Windows batch script instead: `scripts\setup.bat`
- **Option B**: Install Python from [python.org](https://python.org) and ensure it's added to PATH
- **Option C**: In Git Bash, try: `alias python3=python.exe` before running the script

### 2. Docker Issues

**Error**: `docker: command not found`

**Solutions**:
- Install Docker Desktop for Windows from [docker.com](https://docker.com)
- Make sure Docker Desktop is running
- Restart your terminal after installation

### 3. Node.js/npm Issues

**Error**: `node: command not found` or `npm: command not found`

**Solutions**:
- Install Node.js from [nodejs.org](https://nodejs.org)
- Use the LTS version (recommended)
- Restart your terminal after installation

### 4. Permission Issues (Windows)

**Error**: `Access denied` or permission errors

**Solutions**:
- Run your terminal as Administrator
- Check if antivirus is blocking the script
- Ensure you have write permissions in the project directory

### 5. Git Bash Path Issues

**Error**: Path-related issues in Git Bash

**Solutions**:
- Use forward slashes `/` instead of backslashes `\`
- Try running from Command Prompt or PowerShell instead
- Use the `setup.bat` file for native Windows experience

## Manual Setup Steps

If the automatic setup fails, you can set up manually:

### Backend Setup
```bash
cd backend
python -m venv venv

# Windows (Command Prompt)
venv\Scripts\activate.bat

# Windows (PowerShell)
venv\Scripts\Activate.ps1

# Git Bash/Linux/Mac
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt
```

### Frontend Setup
```bash
cd frontend
npm install
```

### Environment Configuration
```bash
cp .env.example .env
# Edit .env file with your configuration
```

### Start Services
```bash
docker-compose up -d postgres redis
```

## Quick Commands Reference

### Start Development Servers
```bash
# Backend (in one terminal)
cd backend
source venv/bin/activate  # or venv\Scripts\activate on Windows
uvicorn api.main:app --reload

# Frontend (in another terminal)
cd frontend
npm run dev
```

### Docker Commands
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# Reset database
docker-compose down -v && docker-compose up -d postgres redis
```

### Python Virtual Environment
```bash
# Create virtual environment
python -m venv venv

# Activate (Windows Command Prompt)
venv\Scripts\activate.bat

# Activate (Windows PowerShell)
venv\Scripts\Activate.ps1

# Activate (Git Bash/Linux/Mac)
source venv/bin/activate

# Deactivate
deactivate
```

## Getting Help

If you're still having issues:

1. Check the error message carefully
2. Try the manual setup steps above
3. Make sure all prerequisites are installed
4. Create an issue on GitHub with the full error message
5. Check the project documentation at `/docs`

## System Requirements

- **Operating System**: Windows 10+, macOS 10.14+, or Linux
- **Python**: 3.9 or higher
- **Node.js**: 18 or higher
- **Docker**: Latest version
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: At least 5GB free space
