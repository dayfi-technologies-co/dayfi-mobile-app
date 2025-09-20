// models/coin_detail_model.dart
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';

class CoinDetail {
  final String id;
  final String name;
  final String symbol;
  final String imageUrl;
  final double currentPrice;
  final double priceChange24h;
  final double marketCap;
  final int popularity;
  final String description;
  final Map<String, dynamic>? additionalData;

  CoinDetail({
    required this.id,
    required this.name,
    required this.symbol,
    required this.imageUrl,
    required this.currentPrice,
    required this.priceChange24h,
    required this.marketCap,
    required this.popularity,
    this.description = '',
    this.additionalData,
  });

  factory CoinDetail.fromJson(Map<String, dynamic> json) {
    return CoinDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      imageUrl: json['image']?['small'] ?? '',
      currentPrice:
          json['market_data']?['current_price']?['usd']?.toDouble() ?? 0.0,
      priceChange24h:
          json['market_data']?['price_change_percentage_24h']?.toDouble() ??
              0.0,
      marketCap: json['market_data']?['market_cap']?['usd']?.toDouble() ?? 0.0,
      popularity: json['market_cap_rank'] ?? 0,
      description: json['description']?['en'] ?? 'No description available.',
      additionalData: json,
    );
  }
}

class ChartData {
  final List<FlSpot> spots;
  final double minY;
  final double maxY;

  ChartData({
    required this.spots,
    required this.minY,
    required this.maxY,
  });
}

class CoinService {
  final Dio _dio = Dio();

  final Map<String, String> binanceSymbols = {
    'bitcoin': 'BTCUSDT',
    'ethereum': 'ETHUSDT',
    'cardano': 'ADAUSDT',
    'solana': 'SOLUSDT',
    'polygon': 'MATICUSDT',
    'stellar': 'XLMUSDT',
    'toncoin': 'TONUSDT',
  };

  final Map<String, String> timeframeIntervals = {
    "1H": "1m",
    "1D": "5m",
    "1W": "1h",
    "1M": "4h",
    "6M": "1d",
    "1Y": "1d",
  };

  final Map<String, int> timeframeDays = {
    "1H": 1,
    "1D": 1,
    "1W": 7,
    "1M": 30,
    "6M": 180,
    "1Y": 365,
  };

  Future<CoinDetail> getCoinDetails(String coinId) async {
    final response = await _dio.get(
      'https://api.coingecko.com/api/v3/coins/$coinId',
      queryParameters: {
        'localization': false,
        'tickers': false,
        'community_data': false,
        'developer_data': false,
      },
    );
    return CoinDetail.fromJson(response.data);
  }

  Future<CoinDetail> getBinanceDetails(String coinId) async {
    final binanceSymbol = binanceSymbols[coinId];
    if (binanceSymbol == null) {
      throw Exception("Data temporarily unavailable");
    }

    final response = await _dio.get(
      'https://api.binance.com/api/v3/ticker/24h',
      queryParameters: {'symbol': binanceSymbol},
    );

    // Map Binance data to our model
    final data = response.data;
    return CoinDetail(
      id: coinId,
      name: coinId.substring(0, 1).toUpperCase() + coinId.substring(1),
      symbol: binanceSymbol.replaceAll('USDT', ''),
      imageUrl: '', // We don't have image from Binance
      currentPrice: double.parse(data['lastPrice']),
      priceChange24h: double.parse(data['priceChangePercent']),
      marketCap: double.parse(data['quoteVolume']),
      popularity: 0, // No rank from Binance
      additionalData: data,
    );
  }

  Future<ChartData> getChartData(String coinId, String timeframe,
      {bool useBinance = false}) async {
    if (!useBinance) {
      try {
        return await _getCoinGeckoChartData(coinId, timeframe);
      } catch (e) {
        return await _getBinanceChartData(coinId, timeframe);
      }
    } else {
      return await _getBinanceChartData(coinId, timeframe);
    }
  }

  Future<ChartData> _getCoinGeckoChartData(
      String coinId, String timeframe) async {
    final days = timeframeDays[timeframe];
    final response = await _dio.get(
      'https://api.coingecko.com/api/v3/coins/$coinId/market_chart',
      queryParameters: {
        'vs_currency': 'usd',
        'days': days,
        'interval': days == 1 ? 'hourly' : 'daily',
      },
    );

    final prices = response.data['prices'] as List;
    final spots = prices.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value[1] as num).toDouble(),
      );
    }).toList();

    double minY = double.infinity;
    double maxY = -double.infinity;

    for (var spot in spots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }

    return ChartData(spots: spots, minY: minY, maxY: maxY);
  }

  Future<ChartData> _getBinanceChartData(
      String coinId, String timeframe) async {
    final binanceSymbol = binanceSymbols[coinId];
    if (binanceSymbol == null) {
      throw Exception("Chart data unavailable");
    }

    final interval = timeframeIntervals[timeframe];
    final response = await _dio.get(
      'https://api.binance.com/api/v3/klines',
      queryParameters: {
        'symbol': binanceSymbol,
        'interval': interval,
        'limit': 500,
      },
    );

    final klines = response.data as List;
    final spots = klines.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        double.parse(entry.value[4]), // Closing price
      );
    }).toList();

    double minY = double.infinity;
    double maxY = -double.infinity;

    for (var spot in spots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }

    return ChartData(spots: spots, minY: minY, maxY: maxY);
  }
}
