#!/bin/bash
# Comprehensive Kointos App Testing Suite

echo "🚀 Starting Kointos App Testing Suite"
echo "======================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please run setup-flutter-env.sh first"
    exit 1
else
    echo "✅ Flutter is installed"
fi

# Navigate to project directory
cd /workspaces/kointos1

# Clean and get dependencies
echo ""
echo "📦 Installing dependencies..."
flutter clean
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to get dependencies"
    exit 1
fi

# Run Flutter doctor to check setup
echo ""
echo "🔍 Checking Flutter setup..."
flutter doctor

# Analyze code
echo ""
echo "🔍 Analyzing code..."
flutter analyze --no-fatal-infos

# Test API server compilation
echo ""
echo "🔧 Testing API server compilation..."
dart compile exe bin/api_server.dart -o bin/api_server_test
if [ $? -eq 0 ]; then
    echo "✅ API server compiles successfully"
    rm -f bin/api_server_test
else
    echo "❌ API server compilation failed"
fi

# Test API server startup
echo ""
echo "🌐 Testing API server startup..."
timeout 10s dart run bin/api_server.dart &
API_PID=$!

# Wait for server to start
sleep 3

# Test API endpoints
echo "Testing API endpoints..."

# Test health endpoint
echo "Testing /health endpoint..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health 2>/dev/null || echo "000")
if [[ "$response" == "200" ]]; then
    echo "✅ Health endpoint working"
else
    echo "❌ Health endpoint failed (HTTP $response)"
fi

# Test version endpoint
echo "Testing /version endpoint..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/version 2>/dev/null || echo "000")
if [[ "$response" == "200" ]]; then
    echo "✅ Version endpoint working"
else
    echo "❌ Version endpoint failed (HTTP $response)"
fi

# Test API docs endpoint
echo "Testing /api-docs endpoint..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api-docs 2>/dev/null || echo "000")
if [[ "$response" == "200" ]]; then
    echo "✅ API docs endpoint working"
else
    echo "❌ API docs endpoint failed (HTTP $response)"
fi

# Stop API server
if [ ! -z "$API_PID" ]; then
    kill $API_PID 2>/dev/null
    wait $API_PID 2>/dev/null
fi

# Kill any remaining processes on port 8080
pkill -f "dart.*api_server" 2>/dev/null || true

# Test Flutter build for web
echo ""
echo "🌐 Testing Flutter web build..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo "✅ Flutter web build successful"
else
    echo "❌ Flutter web build failed"
fi

# Run unit tests if they exist
echo ""
echo "🧪 Running unit tests..."
if [ -d "test" ] && [ "$(ls -A test)" ]; then
    flutter test
    if [ $? -eq 0 ]; then
        echo "✅ Unit tests passed"
    else
        echo "❌ Some unit tests failed"
    fi
else
    echo "ℹ️ No unit tests found"
fi

echo ""
echo "🎉 Testing completed!"
echo "Check the output above for any issues."
