#!/bin/bash

# Quick development server startup script
# This script starts both backend and frontend servers

set -e

echo "🚀 Starting Decision Platform Development Servers..."

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Start background services first
echo "🐳 Starting background services (PostgreSQL, Redis)..."
docker-compose up -d postgres redis

# Wait a moment for services to start
echo "⏳ Waiting for services to initialize..."
sleep 5

# Function to start backend
start_backend() {
    echo "🐍 Starting backend server..."
    cd backend
    
    # Activate virtual environment
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        source venv/Scripts/activate 2>/dev/null || {
            echo "❌ Backend virtual environment not found. Run setup first."
            exit 1
        }
    else
        source venv/bin/activate 2>/dev/null || {
            echo "❌ Backend virtual environment not found. Run setup first."
            exit 1
        }
    fi
    
    # Start FastAPI server
    uvicorn api.main:app --reload --host 0.0.0.0 --port 8000 &
    BACKEND_PID=$!
    echo "✅ Backend server started (PID: $BACKEND_PID)"
    cd ..
}

# Function to start frontend
start_frontend() {
    echo "⚛️ Starting frontend server..."
    cd frontend
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "❌ Frontend dependencies not found. Run setup first."
        exit 1
    fi
    
    # Start Next.js server
    npm run dev &
    FRONTEND_PID=$!
    echo "✅ Frontend server started (PID: $FRONTEND_PID)"
    cd ..
}

# Start both servers
start_backend
start_frontend

echo ""
echo "🎉 Development servers are starting up!"
echo ""
echo "📡 Services:"
echo "  • Backend API: http://localhost:8000"
echo "  • API Documentation: http://localhost:8000/docs"
echo "  • Frontend: http://localhost:3000"
echo "  • PostgreSQL: localhost:5432"
echo "  • Redis: localhost:6379"
echo ""
echo "📋 Useful commands:"
echo "  • View API docs: open http://localhost:8000/docs"
echo "  • View application: open http://localhost:3000"
echo "  • Stop servers: Ctrl+C or run 'scripts/stop-dev.sh'"
echo ""
echo "📊 Logs will appear below. Press Ctrl+C to stop all servers."
echo "────────────────────────────────────────────────────────────"

# Wait for both processes and handle shutdown
trap 'echo ""; echo "🛑 Shutting down servers..."; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; wait; echo "✅ Servers stopped"; exit' INT TERM

# Wait for background processes
wait
