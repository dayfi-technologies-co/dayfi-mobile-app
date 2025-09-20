import 'package:dayfi/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PrepaidInfoViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();

  final List<String> items = [
    "Digital currencies, including stablecoins, offer high liquidity and are available on most major platforms for fast trading.",
    "Certain stablecoins provide security with fully audited reserves, ideal for holding or DeFi investments.",
    "Trade or swap digital currencies with a 0.5% fee, ensuring cost-effective transactions.",
    "Send digital currencies globally in seconds, bypassing banks for seamless transfers.",
    "Stablecoins protect your funds from crypto volatility while enabling DeFi yield opportunities.",
  ];

  final List<String> items2 = [
    "A one-time card issuance fee of \$2 will be charged to your wallet. This includes \$1 for card creation and a \$1 prefund. The total amount is neither withdrawable nor spendable.",
    "You have to complete up to level two of the verification process.",
    "To keep your card active, a small \$1 monthly maintenance fee will apply. This fee will be deducted after your first debit transaction of the month.",
  ];

  bool _isAgreed = false;

  bool get isAgreed => _isAgreed;

  void setAgreed(bool value) {
    _isAgreed = value;
    notifyListeners();
  }

  void navigateBack() {
    navigationService.back();
  }
}
