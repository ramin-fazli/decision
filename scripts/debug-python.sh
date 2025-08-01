#!/bin/bash

# Python Detection Debug Script
# This script helps diagnose Python installation issues

echo "🔍 Python Detection Debug"
echo "=========================="
echo "System: $OSTYPE"
echo "Path: $PATH"
echo ""

echo "🔎 Testing Python commands..."
echo ""

# Test python command
echo -n "python: "
if command -v python &> /dev/null; then
    PYTHON_PATH=$(which python)
    echo "Found at $PYTHON_PATH"
    if python --version 2>/dev/null; then
        echo "  ✅ Working: $(python --version 2>&1)"
    else
        echo "  ❌ Not working (probably Windows Store stub)"
    fi
else
    echo "Not found"
fi

# Test python3 command
echo -n "python3: "
if command -v python3 &> /dev/null; then
    PYTHON3_PATH=$(which python3)
    echo "Found at $PYTHON3_PATH"
    if python3 --version 2>/dev/null; then
        echo "  ✅ Working: $(python3 --version 2>&1)"
    else
        echo "  ❌ Not working (probably Windows Store stub)"
    fi
else
    echo "Not found"
fi

# Test py launcher (Windows)
echo -n "py: "
if command -v py &> /dev/null; then
    PY_PATH=$(which py)
    echo "Found at $PY_PATH"
    if py --version 2>/dev/null; then
        echo "  ✅ Working: $(py --version 2>&1)"
        echo "  📋 Available versions:"
        py -0 2>/dev/null || echo "    Unable to list versions"
    else
        echo "  ❌ Not working"
    fi
else
    echo "Not found"
fi

echo ""
echo "💡 Recommendations:"
echo ""

# Check if any Python is working
if (command -v python &> /dev/null && python --version &> /dev/null) || \
   (command -v python3 &> /dev/null && python3 --version &> /dev/null) || \
   (command -v py &> /dev/null && py --version &> /dev/null); then
    echo "✅ You have a working Python installation!"
else
    echo "❌ No working Python found. Please:"
    echo "   1. Install Python from https://python.org"
    echo "   2. OR disable Windows Store stub:"
    echo "      Settings > Apps > App execution aliases > Turn off Python"
    echo "   3. OR try running: scripts\\setup.bat from Command Prompt"
fi
