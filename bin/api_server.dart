import 'dart:io';
import 'package:kointos/api/services/api_startup.dart';
import 'package:logger/logger.dart';

Future<void> main() async {
  final logger = Logger();
  
  try {
    // Get port from environment variable or use default
    final portStr = Platform.environment['PORT'] ?? '8080';
    final port = int.tryParse(portStr) ?? 8080;
    
    final server = await startApiServer(port: port);
    logger.i('API server is running on http://localhost:$port');
    
    // Listen for termination signals
    ProcessSignal.sigint.watch().listen((_) async {
      logger.i('Shutting down API server...');
      await server.stop();
      exit(0);
    });
    
    ProcessSignal.sigterm.watch().listen((_) async {
      logger.i('Shutting down API server...');
      await server.stop();
      exit(0);
    });
    
  } catch (e, stackTrace) {
    logger.e('Error starting API server', error: e, stackTrace: stackTrace);
    exit(1);
  }
}
