#!/bin/bash

# Stop development servers and clean up

echo "🛑 Stopping Decision Platform development servers..."

# Kill processes on specific ports
echo "🔍 Finding and stopping processes..."

# Stop backend (port 8000)
BACKEND_PID=$(lsof -ti:8000 2>/dev/null)
if [ ! -z "$BACKEND_PID" ]; then
    echo "🐍 Stopping backend server (PID: $BACKEND_PID)..."
    kill $BACKEND_PID
fi

# Stop frontend (port 3000)
FRONTEND_PID=$(lsof -ti:3000 2>/dev/null)
if [ ! -z "$FRONTEND_PID" ]; then
    echo "⚛️ Stopping frontend server (PID: $FRONTEND_PID)..."
    kill $FRONTEND_PID
fi

# Stop Docker services
echo "🐳 Stopping Docker services..."
docker-compose stop postgres redis

echo "✅ All development servers stopped!"
echo ""
echo "💡 To start again, run:"
echo "   ./scripts/start-dev.sh  (Linux/Mac/Git Bash)"
echo "   scripts\\start-dev.bat   (Windows Command Prompt)"
