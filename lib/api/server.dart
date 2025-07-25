import 'dart:convert';
import 'dart:io';

import 'package:kointos/api/middlewares/auth_middleware.dart';
import 'package:kointos/api/routes/article_routes.dart';
import 'package:kointos/api/routes/cryptocurrency_routes.dart';
import 'package:kointos/api/routes/portfolio_routes.dart';
import 'package:kointos/api/routes/post_routes.dart';
import 'package:kointos/api/routes/user_routes.dart';
import 'package:kointos/core/services/service_locator.dart';
import 'package:logger/logger.dart';

class ApiServer {
  final Logger _logger = Logger();
  HttpServer? _server;
  final int port;

  ApiServer({this.port = 8080});

  Future<void> start() async {
    try {
      // Initialize services
      await setupServiceLocator();

      // Create server
      _server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        port,
      ).catchError((error) {
        _logger.e('Failed to start server: $error');
        throw error;
      });
      
      _logger.i('Server running on localhost:$port');

      // Handle requests
      await _server!.forEach((HttpRequest request) async {
        try {
          // Enable CORS
          request.response.headers.add('Access-Control-Allow-Origin', '*');
          request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
          request.response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type, X-Auth-Token, Authorization');
          
          // Security headers
          request.response.headers.add('X-Content-Type-Options', 'nosniff');
          request.response.headers.add('X-Frame-Options', 'DENY');
          request.response.headers.add('Content-Security-Policy', "default-src 'self'");
          request.response.headers.add('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
          
          // Handle preflight requests
          if (request.method == 'OPTIONS') {
            request.response.statusCode = HttpStatus.ok;
            await request.response.close();
            return;
          }

          // Extract path components
          final pathSegments = request.uri.pathSegments;
          if (pathSegments.isEmpty) {
            _sendResponse(request.response, {'status': 'Kointos API Server Running'});
            return;
          }

          // Route to appropriate handlers based on path
          final endpoint = pathSegments[0];
          
          switch (endpoint) {
            case 'users':
              await UserRoutes.handleRequest(request);
              break;
            case 'cryptocurrencies':
              await CryptocurrencyRoutes.handleRequest(request);
              break;
            case 'portfolios':
              await AuthMiddleware.authenticate(request, 
                () => PortfolioRoutes.handleRequest(request));
              break;
            case 'posts':
              await PostRoutes.handleRequest(request);
              break;
            case 'articles':
              await ArticleRoutes.handleRequest(request);
              break;
            case 'health':
              _sendResponse(request.response, {'status': 'ok'});
              break;
            case 'api-docs':
              _sendResponse(request.response, {
                'version': '1.0.0',
                'title': 'Kointos API',
                'description': 'API for Kointos crypto portfolio and social trading platform',
                'endpoints': [
                  {'path': '/users', 'methods': ['GET', 'POST']},
                  {'path': '/users/{id}', 'methods': ['GET', 'PUT', 'DELETE']},
                  {'path': '/cryptocurrencies', 'methods': ['GET']},
                  {'path': '/portfolios', 'methods': ['GET', 'POST']},
                  {'path': '/posts', 'methods': ['GET', 'POST']},
                  {'path': '/articles', 'methods': ['GET', 'POST']},
                ]
              });
              break;
            case 'version':
              _sendResponse(request.response, {'version': '1.0.0'});
              break;
            default:
              request.response.statusCode = HttpStatus.notFound;
              _sendResponse(request.response, {'error': 'Not found'});
          }
        } catch (e, stackTrace) {
          _logger.e('Error processing request: $e', error: e, stackTrace: stackTrace);
          request.response.statusCode = HttpStatus.internalServerError;
          _sendResponse(request.response, {'error': 'Internal server error'});
        }
      });
    } catch (e, stackTrace) {
      _logger.e('Server startup error: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> stop() async {
    await _server?.close();
    _logger.i('Server stopped');
  }

  void _sendResponse(HttpResponse response, Map<String, dynamic> data) {
    response.headers.contentType = ContentType.json;
    response.write(json.encode(data));
    response.close();
  }
}
