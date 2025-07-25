import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kointos/api/services/api_startup.dart';
import 'package:kointos/core/services/auth_service.dart';
import 'package:kointos/core/services/kointos_amplify_config.dart';
import 'package:kointos/core/services/service_locator.dart';
import 'package:kointos/core/theme/modern_theme.dart';
import 'package:kointos/presentation/screens/auth_screen.dart';
import 'package:kointos/presentation/screens/main_tab_screen.dart';
import 'package:kointos/presentation/widgets/first_time_tutorial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  await setupServiceLocator();

  // Configure Amplify
  await KointosAmplifyConfig.configureAmplify();
  
  // Start API server if running in debug mode or if specified via environment
  if (Platform.environment.containsKey('START_API_SERVER') || 
      const bool.fromEnvironment('dart.vm.product') == false) {
    try {
      final port = int.tryParse(Platform.environment['API_PORT'] ?? '8080') ?? 8080;
      await startApiServer(port: port);
      // ignore: avoid_print
      print('API server started on port $port');
    } catch (e) {
      // ignore: avoid_print
      print('Failed to start API server: $e');
    }
  }

  runApp(const KointosApp());
}

class KointosApp extends StatelessWidget {
  const KointosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kointos',
      theme: AppTheme.darkTheme,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  final _authService = getService<AuthService>();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (mounted) {
        setState(() {
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: FirstTimeTutorial(
        child: _isAuthenticated ? const MainTabScreen() : const AuthScreen(),
      ),
    );
  }
}
