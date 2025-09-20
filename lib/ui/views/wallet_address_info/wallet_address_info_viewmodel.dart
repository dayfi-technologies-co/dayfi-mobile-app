import 'package:dayfi/app/app.locator.dart' show locator;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class WalletAddressInfoViewModel extends BaseViewModel {
  final String address;
  final String currency;
  final String network;

  WalletAddressInfoViewModel(
      {required this.address, required this.currency, required this.network});

  void shareAddress() {
    // Placeholder for share functionality
    print('Sharing address: $address');
  }

  final NavigationService navigationService = locator<NavigationService>();
}
