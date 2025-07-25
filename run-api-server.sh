#!/bin/bash

# Check for Flutter/Dart installation
if ! command -v dart &> /dev/null; then
    echo "Dart is not installed. Please install Flutter/Dart first."
    exit 1
fi

# Install dependencies if needed
if [ ! -d "build" ]; then
    echo "Installing dependencies..."
    flutter pub get
fi

# Run the API server
echo "Starting Kointos API server..."
dart run bin/api_server.dart
