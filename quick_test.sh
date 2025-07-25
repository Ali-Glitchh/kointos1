#!/bin/bash
# Quick functionality test

echo "🔍 Quick Kointos Functionality Test"
echo "==================================="

# Check Flutter installation
echo "Checking Flutter..."
if command -v flutter &> /dev/null; then
    echo "✅ Flutter is installed"
    flutter --version
else
    echo "❌ Flutter not found"
    exit 1
fi

# Check Dart installation
echo ""
echo "Checking Dart..."
if command -v dart &> /dev/null; then
    echo "✅ Dart is installed"
    dart --version
else
    echo "❌ Dart not found"
    exit 1
fi

# Check project dependencies
echo ""
echo "Checking project dependencies..."
cd /workspaces/kointos1
if [ -f "pubspec.yaml" ]; then
    echo "✅ pubspec.yaml found"
    flutter pub get
    if [ $? -eq 0 ]; then
        echo "✅ Dependencies installed successfully"
    else
        echo "❌ Failed to install dependencies"
        exit 1
    fi
else
    echo "❌ pubspec.yaml not found"
    exit 1
fi

# Analyze code
echo ""
echo "Analyzing code..."
flutter analyze --no-fatal-infos
if [ $? -eq 0 ]; then
    echo "✅ Code analysis passed"
else
    echo "⚠️ Code analysis found issues (but continuing...)"
fi

# Test API server compilation
echo ""
echo "Testing API server compilation..."
dart compile exe bin/api_server.dart -o bin/api_server_test
if [ $? -eq 0 ]; then
    echo "✅ API server compiles successfully"
    rm -f bin/api_server_test
else
    echo "❌ API server compilation failed"
fi

echo ""
echo "🎉 Quick test completed!"
