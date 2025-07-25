# Kointos - Crypto Portfolio and Social Trading Platform

Kointos is a comprehensive cryptocurrency portfolio tracking and social trading platform built with Flutter.

## Features

- **Portfolio Management**: Track your cryptocurrency investments and monitor performance
- **Market Data**: Real-time cryptocurrency prices and market data
- **Social Trading**: Follow other traders, share insights, and discuss market trends
- **News and Articles**: Stay updated with the latest cryptocurrency news and analysis
- **Performance Analytics**: Visualize your portfolio performance over time

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (Version 3.5.0 or higher)
- [Dart](https://dart.dev/get-dart) (Version 3.5.0 or higher)
- [Git](https://git-scm.com/downloads)

### Quick Setup

We provide a setup script that installs all the necessary components:

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/predictor47/kointos1.git
cd kointos1

# Make the setup script executable
chmod +x setup-flutter-env.sh

# Run the setup script
./setup-flutter-env.sh
```

### Manual Setup

If you prefer to set up manually:

1. **Install Flutter**:
   Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install)

2. **Clone the repository**:
   ```bash
   git clone https://github.com/predictor47/kointos1.git
   cd kointos1
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Generate necessary files**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

### Using Docker

For a containerized development environment:

```bash
# Start the development environment
docker-compose up -d

# Access the Flutter container
docker-compose exec flutter bash

# Inside the container, you can run Flutter commands
flutter run -d web-server --web-port=8000 --web-hostname=0.0.0.0
```

## Project Structure

```
lib/
├── api/               # API server implementation
│   ├── controllers/   # API endpoint controllers
│   ├── middlewares/   # Request middleware (auth, logging, etc.)
│   ├── routes/        # API route definitions
│   ├── services/      # API-specific services
│   └── server.dart    # Main API server implementation
├── core/              # Core application code
│   ├── constants/     # App-wide constants
│   ├── services/      # Application services
│   ├── theme/         # App theming
│   └── utils/         # Utility functions
├── data/              # Data layer
│   ├── datasources/   # Remote and local data sources
│   └── repositories/  # Data repositories
├── domain/            # Business logic and entities
│   └── entities/      # Business entities
└── presentation/      # UI layer
    ├── screens/       # App screens
    └── widgets/       # Reusable widgets
```

## API Server

The project includes a built-in API server for development and testing. To start the API server:

```bash
./run-api-server.sh
```

For API documentation, see [API_README.md](API_README.md).

## Running Tests

```bash
# Run all tests
./run-tests.sh

# Run specific tests
flutter test test/path/to/test_file.dart
```

## Development Environment

We recommend using Visual Studio Code with the following extensions:
- Dart
- Flutter
- Bloc
- Flutter Widget Snippets

Our setup script will install these extensions automatically if VS Code is detected.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Flutter](https://flutter.dev/) for the amazing cross-platform framework
- [CoinGecko API](https://www.coingecko.com/api/documentations/v3) for cryptocurrency market data
- [AWS Amplify](https://aws.amazon.com/amplify/) for backend services
