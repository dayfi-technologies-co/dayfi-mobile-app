import 'dart:async';
import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/app_update_service.dart';
import 'package:dayfi/ui/views/force_update/force_update_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SplashViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _secureStorage = locator<SecureStorageService>();
  final _appUpdateService = locator<AppUpdateService>();

  Future<void> initializeApp() async {
    setBusy(true);
    
    try {
      // Check for app updates first
      final updateStatus = await _appUpdateService.checkForUpdates();
      
      // If force update is required, show force update view
      if (updateStatus is ForceUpdateRequired) {
        // Since ForceUpdateView is not using Stacked routing, we'll navigate to it directly
        // This will be handled by replacing the entire app with the force update view
        _showForceUpdateView(updateStatus);
        return;
      }
      
      // Continue with normal initialization
      await _checkUserStateAndNavigate();
      
      // Show optional update dialog if available
      if (updateStatus is OptionalUpdateAvailable) {
        final context = StackedService.navigatorKey?.currentContext;
        if (context != null) {
          _appUpdateService.showUpdateDialog(context, updateStatus);
        }
      }
    } catch (e) {
      print('Error during app initialization: $e');
      // Navigate to startup view as fallback
      await _navigationService.replaceWithStartupView();
    } finally {
      setBusy(false);
    }
  }

  Future<void> _checkUserStateAndNavigate() async {
    try {
      final firstTime = await _secureStorage.read('first_time_user');
      final token = await _secureStorage.read('user_token');
      final passcode = await _secureStorage.read('user_passcode');

      final bool isFirstTimeUser = firstTime == null || firstTime == 'true';
      final String? userToken = token;
      final String? userPasscode = passcode;

      print("Navigating with: $isFirstTimeUser, $userToken, $userPasscode");

      // Add a small delay for splash screen effect
      await Future.delayed(const Duration(milliseconds: 1500));

      if (isFirstTimeUser && userToken == null) {
        await _navigationService.replaceWithStartupView();
      } else if (userToken == null || userToken.isEmpty) {
        await _navigationService.replaceWithLoginView();
      } else if (userPasscode == null || userPasscode.isEmpty) {
        await _navigationService.replaceWithLoginView();
      } else {
        await _navigationService.replaceWithStartupView();
      }
    } catch (e) {
      print('Error checking user state: $e');
      // Navigate to startup view as fallback
      await _navigationService.replaceWithStartupView();
    }
  }

  void _showForceUpdateView(AppUpdateStatus updateStatus) {
    // Navigate to a MaterialApp with ForceUpdateView as the home
    // This is a workaround since ForceUpdateView is not using Stacked routing
    final context = StackedService.navigatorKey?.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ForceUpdateView(updateStatus: updateStatus),
        ),
        (route) => false,
      );
    }
  }
}
