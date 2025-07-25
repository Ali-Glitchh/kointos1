import 'dart:async';
import 'package:kointos/api/server.dart';
import 'package:logger/logger.dart';

/// Starts the API server and returns the server instance.
/// 
/// The server will listen on the specified [port] (default: 8080).
/// Throws an exception if the server fails to start.
Future<ApiServer> startApiServer({int port = 8080}) async {
  final logger = Logger();
  logger.i('Starting API server on port $port...');
  
  final apiServer = ApiServer(port: port);
  try {
    await apiServer.start();
    logger.i('API server started on port $port');
    return apiServer;
  } catch (e, stackTrace) {
    logger.e('Failed to start API server', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
