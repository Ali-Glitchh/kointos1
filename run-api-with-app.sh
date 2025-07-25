#!/bin/bash
# Start the API server
dart run bin/api_server.dart &
API_PID=$!

# Wait a moment for the API to start
sleep 2

# Run the Flutter app
flutter run --flavor development --target lib/main.dart

# When the Flutter app is closed, also close the API server
kill $API_PID
