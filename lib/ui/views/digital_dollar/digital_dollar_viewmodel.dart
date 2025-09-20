import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/ui/views/wallet_address_info/wallet_address_info_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:math';

class DigitalDollarViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();

  String? selectedCurrency;
  String? selectedNetwork;
  List<Map<String, String>> recentAddresses = [];

  void selectCurrency(String currency) {
    selectedCurrency = currency;
    notifyListeners();
  }

  void selectNetwork(String network) {
    selectedNetwork = network;
    notifyListeners();
  }

  Future<void> generateNewAddress() async {
    if (selectedCurrency != null && selectedNetwork != null) {
      // Simulate generating a new address
      final newAddress = _generateAddress(selectedCurrency!, selectedNetwork!);
      recentAddresses.add({
        'currency': selectedCurrency!,
        'network': selectedNetwork!,
        'address': newAddress
      });
      notifyListeners();
      navigationService.navigateToView(WalletAddressInfoView(
          address: newAddress,
          currency: selectedCurrency!,
          network: selectedNetwork!));
    }
  }

  String _generateAddress(String currency, String network) {
    if (network == 'Stellar') {
      // Stellar addresses start with 'G' + 55 random base32 chars
      return 'G' + _randomBase32(55);
    } else if (network == 'SOL') {
      // Solana addresses are Base58, length between 32–44
      int length = 44;
      return _randomBase58(length);
    }
    return 'UNKNOWN_NETWORK';
  }

// Generate random Base32 for Stellar
  String _randomBase32(int length) {
    const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final rand = Random.secure();
    return List.generate(
        length, (_) => base32Chars[rand.nextInt(base32Chars.length)]).join();
  }

// Generate random Base58 for Solana
  String _randomBase58(int length) {
    const base58Chars =
        '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    final rand = Random.secure();
    return List.generate(
        length, (_) => base58Chars[rand.nextInt(base58Chars.length)]).join();
  }
}
