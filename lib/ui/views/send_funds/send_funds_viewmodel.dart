import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SendFundsViewModel extends BaseViewModel {
  final NavigationService navigationService = NavigationService();

  int _currentAmount = 0;

  int get currentAmount => _currentAmount;

  String get formattedAmount {
    final formatter = NumberFormat("#,##0.${'0' * 2}", 'en_US');
    return formatter.format(_currentAmount);
  }

  void appendNumber(int num) {
    _currentAmount = _currentAmount * 10 + num;
    notifyListeners();
  }

  void backspace() {
    _currentAmount = _currentAmount > 0 ? (_currentAmount ~/ 10) : 0;
    notifyListeners();
  }

  void backToZero() {
    _currentAmount = 0;
    notifyListeners();
  }
}
