#!/bin/bash

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================================${NC}"
echo -e "${BLUE}   Kointos Flutter Environment Setup Script              ${NC}"
echo -e "${BLUE}=========================================================${NC}"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required system dependencies
echo -e "\n${YELLOW}Checking system dependencies...${NC}"

# Check for git
if ! command_exists git; then
  echo -e "${RED}Git is not installed. Installing git...${NC}"
  sudo apt-get update && sudo apt-get install -y git
else
  echo -e "${GREEN}✓ Git is installed${NC}"
fi

# Check for curl
if ! command_exists curl; then
  echo -e "${RED}Curl is not installed. Installing curl...${NC}"
  sudo apt-get update && sudo apt-get install -y curl
else
  echo -e "${GREEN}✓ Curl is installed${NC}"
fi

# Check for unzip
if ! command_exists unzip; then
  echo -e "${RED}Unzip is not installed. Installing unzip...${NC}"
  sudo apt-get update && sudo apt-get install -y unzip
else
  echo -e "${GREEN}✓ Unzip is installed${NC}"
fi

# Check for Flutter
if ! command_exists flutter; then
  echo -e "\n${YELLOW}Flutter is not installed. Installing Flutter...${NC}"
  
  # Create a directory for Flutter installation
  mkdir -p ~/development
  cd ~/development
  
  # Download Flutter SDK
  echo -e "${BLUE}Downloading Flutter SDK...${NC}"
  git clone https://github.com/flutter/flutter.git -b stable
  
  # Add Flutter to PATH
  export PATH="$PATH:$HOME/development/flutter/bin"
  
  # Add Flutter to PATH permanently
  if [[ ":$PATH:" != *":$HOME/development/flutter/bin:"* ]]; then
    echo -e "${BLUE}Adding Flutter to PATH in .bashrc...${NC}"
    echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
  fi
  
  # Verify the installation
  echo -e "${BLUE}Verifying Flutter installation...${NC}"
  flutter doctor
else
  echo -e "${GREEN}✓ Flutter is installed${NC}"
  flutter --version
fi

# Ensure the Flutter SDK is up-to-date
echo -e "\n${YELLOW}Updating Flutter...${NC}"
flutter upgrade

# Install the Dart SDK if it's not already installed
if ! command_exists dart; then
  echo -e "\n${YELLOW}Dart is not properly set up. Setting up Dart...${NC}"
  # Dart should be installed with Flutter, but we'll ensure it's in the path
  export PATH="$PATH:$HOME/development/flutter/bin/cache/dart-sdk/bin"
  
  # Add Dart to PATH permanently
  if [[ ":$PATH:" != *":$HOME/development/flutter/bin/cache/dart-sdk/bin:"* ]]; then
    echo -e "${BLUE}Adding Dart to PATH in .bashrc...${NC}"
    echo 'export PATH="$PATH:$HOME/development/flutter/bin/cache/dart-sdk/bin"' >> ~/.bashrc
  fi
else
  echo -e "${GREEN}✓ Dart is installed${NC}"
  dart --version
fi

# Navigate to the project directory
echo -e "\n${YELLOW}Navigating to the project directory...${NC}"
cd /workspaces/kointos1 || { echo -e "${RED}Error: Could not navigate to project directory${NC}"; exit 1; }

# Get Flutter dependencies
echo -e "\n${YELLOW}Getting Flutter dependencies...${NC}"
flutter pub get

# Build generated files
echo -e "\n${YELLOW}Building generated files (may take a few minutes)...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

# Check if Flutter doctor reports any issues
echo -e "\n${YELLOW}Checking Flutter environment...${NC}"
flutter doctor -v

# Setup development environment variables
echo -e "\n${YELLOW}Setting up development environment variables...${NC}"
if [ ! -f .env.development ]; then
  echo "API_URL=http://localhost:8080" > .env.development
  echo "DEBUG=true" >> .env.development
  echo "ENV=development" >> .env.development
  echo -e "${GREEN}Created .env.development file${NC}"
else
  echo -e "${GREEN}✓ .env.development file already exists${NC}"
fi

# Create a script to run the app with the development environment
echo -e "\n${YELLOW}Creating run scripts...${NC}"
cat > run-dev.sh << 'EOF'
#!/bin/bash
flutter run --flavor development --target lib/main.dart
EOF
chmod +x run-dev.sh

# Create a script to run the API server
cat > run-api-with-app.sh << 'EOF'
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
EOF
chmod +x run-api-with-app.sh

# Install VS Code Flutter extensions if VS Code is being used
if command_exists code; then
  echo -e "\n${YELLOW}Installing recommended VS Code extensions for Flutter development...${NC}"
  code --install-extension Dart-Code.dart-code
  code --install-extension Dart-Code.flutter
  code --install-extension FelixAngelov.bloc
  code --install-extension nash.awesome-flutter-snippets
  
  # Create VS Code settings if they don't exist
  mkdir -p .vscode
  if [ ! -f .vscode/settings.json ]; then
    cat > .vscode/settings.json << 'EOF'
{
  "dart.flutterSdkPath": "~/development/flutter",
  "dart.devToolsTheme": "dark",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  },
  "explorer.fileNesting.enabled": true,
  "explorer.fileNesting.patterns": {
    "*.dart": "${capture}.g.dart, ${capture}.freezed.dart"
  }
}
EOF
    echo -e "${GREEN}Created VS Code settings${NC}"
  else
    echo -e "${GREEN}✓ VS Code settings already exist${NC}"
  fi
  
  # Create launch configuration
  if [ ! -f .vscode/launch.json ]; then
    cat > .vscode/launch.json << 'EOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Kointos (Development)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug",
      "program": "lib/main.dart",
      "args": ["--flavor", "development"]
    },
    {
      "name": "Kointos (Profile)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile",
      "program": "lib/main.dart"
    },
    {
      "name": "Kointos (Release)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release",
      "program": "lib/main.dart"
    },
    {
      "name": "Kointos API Server",
      "request": "launch",
      "type": "dart",
      "program": "bin/api_server.dart",
      "console": "terminal"
    }
  ]
}
EOF
    echo -e "${GREEN}Created VS Code launch configuration${NC}"
  else
    echo -e "${GREEN}✓ VS Code launch configuration already exists${NC}"
  fi
fi

# Create a script to run tests
cat > run-tests.sh << 'EOF'
#!/bin/bash
flutter test
EOF
chmod +x run-tests.sh

echo -e "\n${GREEN}=========================================================${NC}"
echo -e "${GREEN}   Kointos Flutter environment setup complete!           ${NC}"
echo -e "${GREEN}=========================================================${NC}"
echo -e "\n${BLUE}You can now:${NC}"
echo -e "${YELLOW}  - Run the API server:${NC} ./run-api-server.sh"
echo -e "${YELLOW}  - Run the Flutter app in dev mode:${NC} ./run-dev.sh"
echo -e "${YELLOW}  - Run both the API server and app:${NC} ./run-api-with-app.sh"
echo -e "${YELLOW}  - Run tests:${NC} ./run-tests.sh"
echo -e "\n${BLUE}Happy coding!${NC}\n"
