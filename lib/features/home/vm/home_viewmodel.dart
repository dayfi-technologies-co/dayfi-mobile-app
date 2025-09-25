import '../../../base/base_change_notifier.dart';

class HomeViewModel extends BaseChangeNotifier {
  // Example function: fetch user name
  String getUserName() {
    return "John Doe";
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
