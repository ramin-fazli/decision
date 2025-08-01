#!/bin/bash

echo "==================================="
echo "Decision Platform Status Check"
echo "==================================="
echo

# Check if backend is running
echo "Checking Backend Server (FastAPI)..."
if command -v python3 &> /dev/null; then
    python3 -c "
import requests
import sys
try:
    response = requests.get('http://localhost:8000/health', timeout=5)
    if response.status_code == 200:
        print('✅ Backend server is running on http://localhost:8000')
        data = response.json()
        print(f'   Status: {data.get(\"status\", \"unknown\")}')
        print(f'   Environment: {data.get(\"environment\", \"unknown\")}')
    else:
        print('❌ Backend server responded with error:', response.status_code)
except requests.exceptions.RequestException as e:
    print('❌ Backend server is not responding')
    print('   Error:', str(e))
except ImportError:
    print('⚠️  Python requests module not available, skipping backend check')
" 2>/dev/null || echo "⚠️  Could not check backend status (Python/requests not available)"
else
    echo "⚠️  Python not available, skipping backend check"
fi

echo

# Check if frontend is running  
echo "Checking Frontend Server (Next.js)..."
if command -v node &> /dev/null; then
    node -e "
const http = require('http');
const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/',
    method: 'GET',
    timeout: 5000
};

const req = http.request(options, (res) => {
    if (res.statusCode === 200) {
        console.log('✅ Frontend server is running on http://localhost:3000');
    } else {
        console.log('❌ Frontend server responded with error:', res.statusCode);
    }
});

req.on('error', (err) => {
    console.log('❌ Frontend server is not responding');
    console.log('   Error:', err.message);
});

req.on('timeout', () => {
    console.log('❌ Frontend server request timed out');
    req.abort();
});

req.end();
" 2>/dev/null || echo "⚠️  Could not check frontend status"
else
    echo "⚠️  Node.js not available, skipping frontend check"
fi

echo
echo "==================================="
echo "Quick Start Guide:"
echo "==================================="
echo "1. Backend API: http://localhost:8000"
echo "2. API Documentation: http://localhost:8000/docs"
echo "3. Frontend App: http://localhost:3000"
echo
echo "To start servers manually:"
echo "  Backend:  cd backend && python -m uvicorn api.main:app --reload"
echo "  Frontend: cd frontend && npm run dev"
echo
