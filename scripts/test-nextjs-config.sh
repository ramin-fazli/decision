#!/bin/bash

# Test Next.js Standalone Build Configuration
# This script tests if the Next.js configuration produces the required standalone output

set -e

echo "🧪 Testing Next.js Standalone Build Configuration"
echo "================================================"

cd "$(dirname "$0")/../frontend"

# Check if next.config.mjs exists and has standalone output
echo "📋 Checking Next.js configuration..."
if [ -f "next.config.mjs" ]; then
    echo "✅ next.config.mjs found"
    if grep -q "output.*standalone" next.config.mjs; then
        echo "✅ Standalone output configuration found"
    else
        echo "❌ Standalone output configuration missing"
        exit 1
    fi
else
    echo "❌ next.config.mjs not found"
    exit 1
fi

# Check if conflicting next.config.js exists
if [ -f "next.config.js" ]; then
    echo "⚠️  Conflicting next.config.js found - this may cause issues"
    echo "   Recommendation: Remove next.config.js and use only next.config.mjs"
else
    echo "✅ No conflicting next.config.js found"
fi

# Check package.json for required scripts
echo ""
echo "📦 Checking package.json..."
if [ -f "package.json" ]; then
    echo "✅ package.json found"
    if grep -q "\"build\"" package.json; then
        echo "✅ Build script found"
    else
        echo "❌ Build script missing"
        exit 1
    fi
    if grep -q "\"start\"" package.json; then
        echo "✅ Start script found"
    else
        echo "❌ Start script missing"
        exit 1
    fi
else
    echo "❌ package.json not found"
    exit 1
fi

# Check required files and directories
echo ""
echo "📁 Checking project structure..."
required_files=(
    "src/app/layout.tsx"
    "src/app/page.tsx"
    "src/app/not-found.tsx"
    "src/app/error.tsx"
    "src/app/loading.tsx"
    "src/app/api/health/route.ts"
    "Dockerfile"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# Test build locally (optional - only if dependencies are installed)
if [ -d "node_modules" ] && [ "$1" = "--test-build" ]; then
    echo ""
    echo "🔨 Testing local build..."
    echo "This may take a few minutes..."
    
    # Set environment variables for build
    export NEXT_TELEMETRY_DISABLED=1
    export NODE_ENV=production
    
    # Run build
    if npm run build > build_test.log 2>&1; then
        echo "✅ Build completed successfully"
        
        # Check if standalone output was created
        if [ -d ".next/standalone" ]; then
            echo "✅ Standalone output directory created"
            ls -la .next/standalone/
        else
            echo "❌ Standalone output directory not created"
            echo "Build log:"
            cat build_test.log
            exit 1
        fi
        
        # Clean up
        rm -f build_test.log
        echo "✅ Build test completed successfully"
    else
        echo "❌ Build failed"
        echo "Build log:"
        cat build_test.log
        rm -f build_test.log
        exit 1
    fi
else
    echo ""
    echo "ℹ️  To test the build locally, run:"
    echo "   npm install && $0 --test-build"
fi

echo ""
echo "✅ All configuration checks passed!"
echo ""
echo "🐳 Docker Build Tips:"
echo "   - The Dockerfile expects .next/standalone directory"
echo "   - Make sure output: 'standalone' is in next.config.mjs"
echo "   - Remove any conflicting next.config.js file"
echo "   - Health endpoint should be available at /api/health"
echo ""
echo "🚀 Ready for deployment!"
