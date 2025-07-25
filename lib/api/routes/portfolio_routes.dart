import 'dart:convert';
import 'dart:io';

import 'package:kointos/api/controllers/portfolio_controller.dart';
import 'package:logger/logger.dart';

class PortfolioRoutes {
  static final Logger _logger = Logger();
  static final PortfolioController _controller = PortfolioController();

  static Future<void> handleRequest(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    
    try {
      // Route: /portfolios
      if (segments.length == 1) {
        switch (request.method) {
          case 'GET':
            await _controller.getUserPortfolios(request);
            break;
          case 'POST':
            await _controller.createPortfolio(request);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /portfolios/{id}
      if (segments.length == 2) {
        final portfolioId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getPortfolioById(request, portfolioId);
            break;
          case 'PUT':
            await _controller.updatePortfolio(request, portfolioId);
            break;
          case 'DELETE':
            await _controller.deletePortfolio(request, portfolioId);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /portfolios/{id}/items
      if (segments.length == 3 && segments[2] == 'items') {
        final portfolioId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getPortfolioItems(request, portfolioId);
            break;
          case 'POST':
            await _controller.addPortfolioItem(request, portfolioId);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /portfolios/{id}/items/{itemId}
      if (segments.length == 4 && segments[2] == 'items') {
        final portfolioId = segments[1];
        final itemId = segments[3];
        
        switch (request.method) {
          case 'GET':
            await _controller.getPortfolioItemById(request, portfolioId, itemId);
            break;
          case 'PUT':
            await _controller.updatePortfolioItem(request, portfolioId, itemId);
            break;
          case 'DELETE':
            await _controller.deletePortfolioItem(request, portfolioId, itemId);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /portfolios/{id}/performance
      if (segments.length == 3 && segments[2] == 'performance') {
        final portfolioId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getPortfolioPerformance(request, portfolioId);
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
      _logger.e('Error handling portfolio request: $e', error: e, stackTrace: stackTrace);
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
