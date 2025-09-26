import 'dart:async';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _secureStorage = locator<SecureStorageService>();

  PageController? _pageController;
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  bool _isAutoAdvancing = true;
  double _animationValue = 0.0;

  PageController get pageController => _pageController!;
  int get currentPage => _currentPage;
  bool get isAutoAdvancing => _isAutoAdvancing;
  double get animationValue => _animationValue;
  NavigationService get navigationService => _navigationService;

  List<String> get titles => [
    'Connect with loved\nones globally',
    'Worldwide reach,\nlocal touch',
    'Bank-grade\nsecurity',
    'Lightning-fast \ntransfers'
  ];

  List<String> get descriptions => [
    'Bridge distances with instant money transfers across borders.',
    'Access 40+ countries with 30+ currencies at your fingertips.',
    'Advanced encryption and fraud protection for every transaction.',
    'Funds arrive in minutes, not days, to your recipients.'
  ];

  void initialise() {
    _pageController = PageController();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController != null && _currentPage < titles.length - 1) {
        _pageController!.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      } else if (_currentPage == titles.length - 1) {
        _stopAutoAdvance();
      }
    });
  }

  void _stopAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _isAutoAdvancing = false;
    notifyListeners();
  }

  void setPageIndex(int index) {
    _currentPage = index;
    _animationValue = 1.0; // Reset animation value when page changes
    notifyListeners();
    
    // Stop auto-advance if we reach the last page
    if (index == titles.length - 1) {
      _stopAutoAdvance();
    }
  }

  void onPageChanged(int index) {
    setPageIndex(index);
  }

  void onPageTapped() {
    // Stop auto-advance when user manually interacts
    if (_isAutoAdvancing) {
      _stopAutoAdvance();
    }
  }

  Future<void> saveFirstTimeUser() async {
    await _secureStorage.write('first_time_user', 'false');
  }

  Future<void> replaceWithSignupView() async {
    await _navigationService.replaceWithSignupView();
  }

  Future<void> replaceWithLoginView() async {
    await _navigationService.replaceWithLoginView();
  }
}