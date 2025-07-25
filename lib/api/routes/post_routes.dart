import 'dart:convert';
import 'dart:io';

import 'package:kointos/api/controllers/post_controller.dart';
import 'package:kointos/api/middlewares/auth_middleware.dart';
import 'package:logger/logger.dart';

class PostRoutes {
  static final Logger _logger = Logger();
  static final PostController _controller = PostController();

  static Future<void> handleRequest(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    
    try {
      // Route: /posts
      if (segments.length == 1) {
        switch (request.method) {
          case 'GET':
            await _controller.getAllPosts(request);
            break;
          case 'POST':
            await AuthMiddleware.authenticate(
                request, () => _controller.createPost(request));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /posts/{id}
      if (segments.length == 2) {
        final postId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getPostById(request, postId);
            break;
          case 'PUT':
            await AuthMiddleware.authenticate(
                request, () => _controller.updatePost(request, postId));
            break;
          case 'DELETE':
            await AuthMiddleware.authenticate(
                request, () => _controller.deletePost(request, postId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /posts/{id}/like
      if (segments.length == 3 && segments[2] == 'like') {
        final postId = segments[1];
        
        switch (request.method) {
          case 'POST':
            await AuthMiddleware.authenticate(
                request, () => _controller.likePost(request, postId));
            break;
          case 'DELETE':
            await AuthMiddleware.authenticate(
                request, () => _controller.unlikePost(request, postId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /posts/{id}/comments
      if (segments.length == 3 && segments[2] == 'comments') {
        final postId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getPostComments(request, postId);
            break;
          case 'POST':
            await AuthMiddleware.authenticate(
                request, () => _controller.addPostComment(request, postId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /posts/user/{userId}
      if (segments.length == 3 && segments[1] == 'user') {
        final userId = segments[2];
        
        switch (request.method) {
          case 'GET':
            await _controller.getUserPosts(request, userId);
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
      _logger.e('Error handling post request: $e', error: e, stackTrace: stackTrace);
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
