import 'dart:convert';
import 'package:kointos/core/constants/app_constants.dart';
import 'package:kointos/core/services/local_storage_service.dart';
import 'package:kointos/data/datasources/coingecko_service.dart';
import 'package:kointos/domain/entities/cryptocurrency.dart';

class CryptocurrencyRepository {
  final CoinGeckoService coinGeckoService;
  final LocalStorageService localStorageService;

  const CryptocurrencyRepository({
    required this.coinGeckoService,
    required this.localStorageService,
  });

  Future<List<Cryptocurrency>> getTopCryptocurrencies({
    int page = 1,
    int perPage = 100,
    String currency = 'usd',
  }) async {
    try {
      // Try to get cached data first
      final cachedData =
          await localStorageService.get(AppConstants.cryptoCacheKey);
      if (cachedData != null) {
        final List<dynamic> cached = json.decode(cachedData);
        final cryptos =
            cached.map((data) => Cryptocurrency.fromJson(data)).toList();
        return cryptos;
      }

      // If no cache, fetch from API
      final cryptos = await coinGeckoService.getMarketData(
        currency: currency,
        page: page,
        perPage: perPage,
      );

      // Cache the results
      await localStorageService.set(
        AppConstants.cryptoCacheKey,
        json.encode(cryptos.map((c) => c.toJson()).toList()),
        expiry: AppConstants.cryptoCacheDuration,
      );

      return cryptos;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMarketStats() async {
    try {
      // Try to get cached data first
      final cachedData =
          await localStorageService.get(AppConstants.marketDataCacheKey);
      if (cachedData != null) {
        return json.decode(cachedData);
      }

      // If no cache, fetch from API
      final data = await coinGeckoService.getGlobalData();

      // Cache the results
      await localStorageService.set(
        AppConstants.marketDataCacheKey,
        json.encode(data),
        expiry: AppConstants.marketDataCacheDuration,
      );

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Cryptocurrency>> searchCryptocurrencies(String query) async {
    try {
      return await coinGeckoService.searchCryptocurrencies(query);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<double>> getCryptocurrencyPriceHistory(
    String id,
    String currency,
    int days,
  ) async {
    try {
      return await coinGeckoService.getHistoricalPrices(
        id,
        currency,
        days,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCache() async {
    try {
      await localStorageService.remove(AppConstants.cryptoCacheKey);
      await localStorageService.remove(AppConstants.marketDataCacheKey);
    } catch (e) {
      rethrow;
    }
  }

  // Add missing methods for API controllers
  Future<Cryptocurrency?> getCryptocurrencyById(String cryptoId) async {
    try {
      final cryptos = await getTopCryptocurrencies();
      return cryptos.firstWhere((crypto) => crypto.id == cryptoId);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getCryptoMarketData({
    String currency = 'usd',
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final cryptos = await getTopCryptocurrencies(
        currency: currency,
        page: page,
        perPage: limit,
      );
      return {
        'data': cryptos.map((c) => c.toJson()).toList(),
        'page': page,
        'total': cryptos.length,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Cryptocurrency>> getTrendingCryptocurrencies() async {
    try {
      // Get top cryptocurrencies and sort by price change
      final cryptos = await getTopCryptocurrencies(perPage: 50);
      cryptos.sort((a, b) => (b.priceChangePercentage24h ?? 0).compareTo(a.priceChangePercentage24h ?? 0));
      return cryptos.take(10).toList();
    } catch (e) {
      rethrow;
    }
  }
}
