import 'dart:convert';
import 'dart:io';

import 'package:kointos/api/controllers/article_controller.dart';
import 'package:kointos/api/middlewares/auth_middleware.dart';
import 'package:logger/logger.dart';

class ArticleRoutes {
  static final Logger _logger = Logger();
  static final ArticleController _controller = ArticleController();

  static Future<void> handleRequest(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    
    try {
      // Route: /articles
      if (segments.length == 1) {
        switch (request.method) {
          case 'GET':
            await _controller.getAllArticles(request);
            break;
          case 'POST':
            await AuthMiddleware.authenticate(
                request, () => _controller.createArticle(request));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /articles/{id}
      if (segments.length == 2) {
        final articleId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getArticleById(request, articleId);
            break;
          case 'PUT':
            await AuthMiddleware.authenticate(
                request, () => _controller.updateArticle(request, articleId));
            break;
          case 'DELETE':
            await AuthMiddleware.authenticate(
                request, () => _controller.deleteArticle(request, articleId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /articles/{id}/like
      if (segments.length == 3 && segments[2] == 'like') {
        final articleId = segments[1];
        
        switch (request.method) {
          case 'POST':
            await AuthMiddleware.authenticate(
                request, () => _controller.likeArticle(request, articleId));
            break;
          case 'DELETE':
            await AuthMiddleware.authenticate(
                request, () => _controller.unlikeArticle(request, articleId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /articles/{id}/comments
      if (segments.length == 3 && segments[2] == 'comments') {
        final articleId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getArticleComments(request, articleId);
            break;
          case 'POST':
            await AuthMiddleware.authenticate(
                request, () => _controller.addArticleComment(request, articleId));
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /articles/featured
      if (segments.length == 2 && segments[1] == 'featured') {
        switch (request.method) {
          case 'GET':
            await _controller.getFeaturedArticles(request);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /articles/user/{userId}
      if (segments.length == 3 && segments[1] == 'user') {
        final userId = segments[2];
        
        switch (request.method) {
          case 'GET':
            await _controller.getUserArticles(request, userId);
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
      _logger.e('Error handling article request: $e', error: e, stackTrace: stackTrace);
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
