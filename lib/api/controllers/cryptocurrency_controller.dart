import 'dart:convert';
import 'dart:io';

import 'package:kointos/core/constants/app_constants.dart';
import 'package:kointos/core/services/service_locator.dart';
import 'package:kointos/data/repositories/cryptocurrency_repository.dart';
import 'package:logger/logger.dart';

class CryptocurrencyController {
  final Logger _logger = Logger();
  final CryptocurrencyRepository _repository = getService<CryptocurrencyRepository>();
  
  Future<void> getAllCryptocurrencies(HttpRequest request) async {
    try {
      // Get query parameters
      final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final perPage = int.tryParse(request.uri.queryParameters['per_page'] ?? '${AppConstants.defaultPageSize}') 
          ?? AppConstants.defaultPageSize;
      final currency = request.uri.queryParameters['currency'] ?? 'usd';
      
      // Get cryptocurrencies from repository
      final cryptocurrencies = await _repository.getTopCryptocurrencies(
        page: page,
        perPage: perPage,
        currency: currency,
      );
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'data': cryptocurrencies.map((crypto) => crypto.toJson()).toList(),
        'page': page,
        'per_page': perPage,
        'currency': currency,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting cryptocurrencies: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve cryptocurrencies'});
    }
  }

  Future<void> getCryptocurrencyById(HttpRequest request, String cryptoId) async {
    try {
      final cryptocurrency = await _repository.getCryptocurrencyById(cryptoId);
      
      if (cryptocurrency == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'Cryptocurrency not found'});
        return;
      }
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, cryptocurrency.toJson());
    } catch (e, stackTrace) {
      _logger.e('Error getting cryptocurrency: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve cryptocurrency'});
    }
  }

  Future<void> getCryptoMarketData(HttpRequest request, String cryptoId) async {
    try {
      // Get query parameters
      final days = int.tryParse(request.uri.queryParameters['days'] ?? '7') ?? 7;
      final currency = request.uri.queryParameters['currency'] ?? 'usd';
      
      // Get market data from repository
      final marketData = await _repository.getCryptocurrencyPriceHistory(
        cryptoId,
        currency,
        days,
      );
      
      if (marketData.isEmpty) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'Market data not found'});
        return;
      }
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'cryptoId': cryptoId,
        'currency': currency,
        'days': days,
        'prices': marketData,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting market data: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve market data'});
    }
  }

  Future<void> getTrendingCryptos(HttpRequest request) async {
    try {
      // Get trending cryptocurrencies from repository
      final trendingCryptos = await _repository.getTrendingCryptocurrencies();
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'data': trendingCryptos.map((crypto) => crypto.toJson()).toList(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting trending cryptocurrencies: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve trending cryptocurrencies'});
    }
  }

  void _sendJsonResponse(HttpResponse response, Map<String, dynamic> data) {
    response.headers.contentType = ContentType.json;
    response.write(json.encode(data));
    response.close();
  }
}
