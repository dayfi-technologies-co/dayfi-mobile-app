import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../data/storage/secure_storage_service.dart';

class StartupViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final PageController _pageController = PageController();
  final SecureStorageService secureStorage = locator<SecureStorageService>();

  final List<String> titles = [
    // 'Borderless payment options for everyone.',
    // 'Borderless payment options for everyone',
    // 'Buy and Sell Crypto Easily Anytime',
    'Your everyday\nmoney app',
  ];

  final List<String> descriptions = [
    // 'Get paid instantly—accept contactless cards via NFC or camera.',
    'Sending money shouldn\'t be the source of worry anymore, the solution is here.',
    // 'Buy or sell top cryptocurrencies quickly and securely, all in one app.',
  ];

  double _animationValue = 0.0;
  int _currentPage = 0;
  Timer? _timer;

  // Getters
  PageController get pageController => _pageController;
  int get currentPage => _currentPage;
  double get animationValue => _animationValue;
  NavigationService get navigationService => _navigationService;

  StartupViewModel() {
    _startAutoScroll();
  }

  void saveFirstTimeUser() {
    secureStorage.write('first_time_user', 'false');
  }

  void setPageIndex(int index) {
    _currentPage = index;
    _animationValue = 0; // reset progress bar
    notifyListeners();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _animationValue += 0.01; // 50 ms * 100 ≈ 5 s
      // if (_animationValue >= 1) {
      //   _animationValue = 0;
      //   final next = (_currentPage + 1) % titles.length;
      //   _pageController.animateToPage(
      //     next,
      //     duration: const Duration(milliseconds: 350),
      //     curve: Curves.easeInOut,
      //   );
      // }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
