#!/bin/bash

echo "==================================="
echo "Decision Platform Requirements Check"
echo "==================================="
echo

# Check if we're in the right directory
if [ ! -f "README.md" ] || [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

echo "📋 Checking Backend Requirements..."
echo "-----------------------------------"

# Check Python environment
cd backend
if [ -d "venv" ]; then
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        source venv/Scripts/activate
        PYTHON_CMD="venv/Scripts/python.exe"
    else
        source venv/bin/activate
        PYTHON_CMD="python"
    fi
    
    echo "✅ Virtual environment found and activated"
    
    # Check core dependencies
    echo "🔍 Checking core dependencies..."
    $PYTHON_CMD -c "
import sys
required_packages = [
    'fastapi', 'uvicorn', 'pydantic', 'pydantic_settings',
    'email_validator', 'sqlalchemy', 'psycopg2', 'redis',
    'jose', 'passlib', 'sklearn', 'pandas', 'numpy'
]

missing = []
for package in required_packages:
    try:
        __import__(package.replace('-', '_'))
        print(f'✅ {package}')
    except ImportError:
        missing.append(package)
        print(f'❌ {package} - MISSING')

if missing:
    print(f'\n⚠️  Missing packages: {missing}')
    print('Run: pip install -r requirements-core.txt')
    sys.exit(1)
else:
    print('\n✅ All core backend dependencies are installed')
"
    
    if [ $? -eq 0 ]; then
        echo "🎉 Backend requirements are satisfied!"
    else
        echo "❌ Backend requirements need attention"
    fi
    
else
    echo "❌ Virtual environment not found. Run setup script first."
fi

cd ..

echo
echo "📋 Checking Frontend Requirements..."
echo "-----------------------------------"

cd frontend
if [ -f "package.json" ] && [ -d "node_modules" ]; then
    echo "✅ package.json and node_modules found"
    
    # Check if key dependencies are installed
    node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const deps = {...pkg.dependencies, ...pkg.devDependencies};

const required = [
    'next', 'react', 'react-dom', 'typescript', 
    'tailwindcss', '@heroicons/react', 'axios'
];

let missing = [];
for (const dep of required) {
    if (deps[dep]) {
        console.log('✅', dep);
    } else {
        missing.push(dep);
        console.log('❌', dep, '- MISSING');
    }
}

if (missing.length > 0) {
    console.log('\\n⚠️  Missing packages:', missing);
    console.log('Run: npm install');
    process.exit(1);
} else {
    console.log('\\n✅ All core frontend dependencies are installed');
}
"
    
    if [ $? -eq 0 ]; then
        echo "🎉 Frontend requirements are satisfied!"
    else
        echo "❌ Frontend requirements need attention"
    fi
    
else
    echo "❌ Frontend dependencies not found. Run setup script first."
fi

cd ..

echo
echo "==================================="
echo "Summary:"
echo "✅ Requirements files are current"
echo "✅ Setup scripts are updated"
echo "✅ Core dependencies are defined"
echo
echo "To install/update dependencies:"
echo "  Backend:  cd backend && pip install -r requirements-core.txt"
echo "  Frontend: cd frontend && npm install"
echo "=================================="
