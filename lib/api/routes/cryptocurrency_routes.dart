import 'dart:convert';
import 'dart:io';

import 'package:kointos/api/controllers/cryptocurrency_controller.dart';
import 'package:logger/logger.dart';

class CryptocurrencyRoutes {
  static final Logger _logger = Logger();
  static final CryptocurrencyController _controller = CryptocurrencyController();

  static Future<void> handleRequest(HttpRequest request) async {
    final segments = request.uri.pathSegments;
    
    try {
      // Route: /cryptocurrencies
      if (segments.length == 1) {
        switch (request.method) {
          case 'GET':
            await _controller.getAllCryptocurrencies(request);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /cryptocurrencies/{id}
      if (segments.length == 2) {
        final cryptoId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getCryptocurrencyById(request, cryptoId);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /cryptocurrencies/{id}/market-data
      if (segments.length == 3 && segments[2] == 'market-data') {
        final cryptoId = segments[1];
        
        switch (request.method) {
          case 'GET':
            await _controller.getCryptoMarketData(request, cryptoId);
            break;
          default:
            _methodNotAllowed(request);
        }
        return;
      }

      // Route: /cryptocurrencies/trending
      if (segments.length == 2 && segments[1] == 'trending') {
        switch (request.method) {
          case 'GET':
            await _controller.getTrendingCryptos(request);
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
      _logger.e('Error handling cryptocurrency request: $e', error: e, stackTrace: stackTrace);
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
