import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfi/base/base_change_notifier.dart';

final loginViewModelProvider = ChangeNotifierProvider<LoginViewModel>((ref) {
  return LoginViewModel();
});

class LoginViewModel extends BaseChangeNotifier {
  // Example function: fetch user name
  String getUserName() {
    return "Guest User";
  }

  // Example function: simulate loading
  Future<void> simulateLoading() async {
    setLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    setLoading(false);
  }

  // Example function: get random number
  int getRandomNumber() {
    return DateTime.now().millisecondsSinceEpoch % 100;
  }
}
