import 'dart:convert';
import 'dart:io';

import 'package:kointos/core/services/auth_service.dart';
import 'package:kointos/core/services/service_locator.dart';
import 'package:logger/logger.dart';

class AuthMiddleware {
  static final Logger _logger = Logger();

  static Future<void> authenticate(
      HttpRequest request, Future<void> Function() handler) async {
    try {
      final authService = getService<AuthService>();
      
      // Check for auth token in header
      final authHeader = request.headers.value('Authorization');
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.headers.contentType = ContentType.json;
        request.response.write(json.encode({'error': 'Authentication required'}));
        await request.response.close();
        return;
      }
      
      final token = authHeader.substring(7); // Remove 'Bearer ' prefix
      
      // Validate the token
      final isValid = await authService.validateToken(token);
      if (!isValid) {
        request.response.statusCode = HttpStatus.unauthorized;
        request.response.headers.contentType = ContentType.json;
        request.response.write(json.encode({'error': 'Invalid or expired token'}));
        await request.response.close();
        return;
      }
      
      // Token is valid, proceed with handling the request
      await handler();
      
    } catch (e, stackTrace) {
      _logger.e('Authentication error: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode({'error': 'Authentication error'}));
      await request.response.close();
    }
  }
}
