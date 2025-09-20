// coin_details_viewmodel.dart
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/ui/views/coin_detail/coin_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CoinDetailViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  final CoinService _coinService = CoinService();

  final String coinId;
  final String initialName;
  final dynamic initialPrice;
  final dynamic initialPriceChange;
  final dynamic initialMarketCap;
  final dynamic initialPopularity;

  CoinDetail? _coinDetail;
  ChartData? _chartData;
  bool _isFavorite = false;
  bool isDescriptionExpandedValue = false;
  String _selectedTimeframe = "1M";
  String _currentApi = 'coingecko';

  final List<String> timeframes = ["1H", "1D", "1W", "1M", "6M", "1Y"];

  CoinDetail? get coinDetail => _coinDetail;
  ChartData? get chartData => _chartData;
  bool get isFavorite => _isFavorite;
  bool get isDescriptionExpanded => isDescriptionExpandedValue;
  String get selectedTimeframe => _selectedTimeframe;
  String get currentApi => _currentApi;

  CoinDetailViewModel({
    required this.coinId,
    required this.initialName,
    required this.initialPrice,
    required this.initialPriceChange,
    required this.initialMarketCap,
    required this.initialPopularity,
  });

  Future<void> initialize() async {
    await runBusyFuture(_fetchData());
  }

  Future<void> _fetchData() async {
    try {
      await Future.wait([
        _fetchCoinDetails(),
        _fetchChartData(),
      ]);
    } catch (e) {
      setError(e);
    }
  }

  Future<void> _fetchCoinDetails() async {
    try {
      _coinDetail = await _coinService.getCoinDetails(coinId);
      _currentApi = 'coingecko';
    } catch (e) {
      _currentApi = 'binance';
      try {
        _coinDetail = await _coinService.getBinanceDetails(coinId);
      } catch (error) {
        throw Exception("Unable to fetch coin details: $error");
      }
    }
  }

  Future<void> _fetchChartData() async {
    try {
      _chartData = await _coinService.getChartData(coinId, _selectedTimeframe,
          useBinance: _currentApi == 'binance');
    } catch (e) {
      // We'll just have null chart data but won't throw an error
      // as this is not critical for the page to function
    }
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  void toggleDescriptionExpanded() {
    isDescriptionExpandedValue = !isDescriptionExpandedValue;
    notifyListeners();
  }

  Future<void> setTimeframe(String timeframe) async {
    _selectedTimeframe = timeframe;
    notifyListeners();

    await runBusyFuture(_fetchChartData(), busyObject: 'chart');
  }

  Future<void> retry() async {
    clearErrors();
    await initialize();
  }
}
