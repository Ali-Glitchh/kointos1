import 'dart:convert';
import 'dart:io';

import 'package:kointos/api/controllers/user_controller.dart';
import 'package:kointos/api/middlewares/auth_middleware.dart';
import 'package:logger/logger.dart';

class UserRoutes {
  static final Logger _logger = Logger();
  static final UserController _controller = UserController();

  static Future<void> handleRequest(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    
    try {
      // Route: /users
      if (segments.length == 1) {
        switch (request.method) {
          case 'GET':
            await _controller.getAllUsers(request);
            break;
          case 'POST':
            await _controller.createUser(request);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /users/{id}
      if (segments.length == 2) {
        final userId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getUserById(request, userId);
            break;
          case 'PUT':
            await AuthMiddleware.authenticate(
                request, () => _controller.updateUser(request, userId));
            break;
          case 'DELETE':
            await AuthMiddleware.authenticate(
                request, () => _controller.deleteUser(request, userId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /users/{id}/profile
      if (segments.length == 3 && segments[2] == 'profile') {
        final userId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getUserProfile(request, userId);
            break;
          case 'PUT':
            await AuthMiddleware.authenticate(
                request, () => _controller.updateUserProfile(request, userId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /users/{id}/follow
      if (segments.length == 3 && segments[2] == 'follow') {
        final userId = segments[1];
        
        switch (request.method) {
          case 'POST':
            await AuthMiddleware.authenticate(
                request, () => _controller.followUser(request, userId));
            break;
          case 'DELETE':
            await AuthMiddleware.authenticate(
                request, () => _controller.unfollowUser(request, userId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route not found
      request.response.statusCode = HttpStatus.notFound;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode({'error': 'Resource not found'}));
      await request.response.close();
      
    } catch (e, stackTrace) {
      _logger.e('Error handling user request: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.json;
      request.response.write(json.encode({'error': 'Internal server error'}));
      await request.response.close();
    }
  }

  static Future<void> _methodNotAllowed(HttpRequest request) async {
    request.response.statusCode = HttpStatus.methodNotAllowed;
    request.response.headers.contentType = ContentType.json;
    request.response.write(json.encode({'error': 'Method not allowed'}));
    await request.response.close();
  }
}
