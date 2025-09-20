import 'dart:convert';

import 'package:dayfi/app/app.locator.dart';
import 'package:dayfi/app/app.router.dart';
import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:dayfi/services/api/auth_api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../components/top_snack_bar.dart';

class SettingsViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();
  final SecureStorageService _secureStorage = locator<SecureStorageService>();
  final AuthApiService _apiService = AuthApiService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  final List<SettingsSectionModel> settingsSections = [
    SettingsSectionModel(
      header: 'Account',
      settingsSectionTiles: [
        SettingSectionTileModel(
          title: "Profile Information",
          description: "Manage your personal details",
          icon: "assets/svgs/person_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
      ],
    ),
    SettingsSectionModel(
      header: 'Banks',
      settingsSectionTiles: [
        SettingSectionTileModel(
          title: "Saved Banks",
          description: "Manage your saved bank accounts",
          icon:
              "assets/svgs/account_balance_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
      ],
    ),
    SettingsSectionModel(
      header: 'Security Settings',
      settingsSectionTiles: [
        SettingSectionTileModel(
          title: "Change Transaction PIN",
          description: "Change the pin for all your transactions",
          icon: "assets/svgs/key_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
        SettingSectionTileModel(
          title: "Reset Transaction PIN",
          description: "Reset your transaction pin",
          icon: "assets/svgs/lock_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
        SettingSectionTileModel(
          title: "Change Password",
          description: "Update your login password",
          icon:
              "assets/svgs/visibility_lock_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
        SettingSectionTileModel(
          title: "Two-Factor Authentication",
          description: "Enhance your account security with 2FA",
          icon:
              "assets/svgs/encrypted_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
      ],
    ),
    SettingsSectionModel(
      header: 'Referral',
      settingsSectionTiles: [
        SettingSectionTileModel(
          title: "Invite and Earn",
          description: "Get rewards when you refer friends",
          icon:
              "assets/svgs/featured_seasonal_and_gifts_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
      ],
    ),
    SettingsSectionModel(
      header: 'About Dayfi',
      settingsSectionTiles: [
        SettingSectionTileModel(
          title: "FAQs",
          description: "Find answers to common questions",
          icon:
              "assets/svgs/contact_support_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
        SettingSectionTileModel(
          title: "Official Website",
          description: "Visit our homepage for more info",
          icon:
              "assets/svgs/captive_portal_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
        SettingSectionTileModel(
          title: "Latest Updates",
          description: "Stay informed with our news and blog",
          icon:
              "assets/svgs/brand_awareness_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
        SettingSectionTileModel(
          title: "Support",
          description: "Need help? Contact our support team",
          icon:
              "assets/svgs/ear_sound_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
      ],
    ),
    SettingsSectionModel(
      header: 'Account Options',
      settingsSectionTiles: [
        SettingSectionTileModel(
          title: "Log Out",
          description: "Sign out from your Dayfi account",
          icon:
              "assets/svgs/exit_to_app_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg",
        ),
      ],
    ),
  ];

  User? user;

  Future<void> loadUser() async {
    final userJson = await _secureStorage.read('user');
    if (userJson != null) {
      user = User.fromJson(json.decode(userJson));
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _secureStorage.read('user_token');
      if (token == null) {
        throw Exception('No token found. Please log in again.');
      }

      final response = await _apiService.logout(jwtToken: user!.token!);

      if (response.code == 200) {
        await _secureStorage.delete('user_token');
        await _secureStorage.delete('user_passcode');
        await _secureStorage.delete('first_time_user');
        await _secureStorage.delete('user');
        await _secureStorage.delete('password');
        await _secureStorage.deleteAll();

        navigationService.clearStackAndShow(Routes.loginView);
      } else {
        throw Exception('Logout failed: ${response.message}');
      }
    } catch (e) {
      TopSnackbar.show(
        context,
        message: 'Error during logout: ${e.toString()}',
        isError: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class SettingsSectionModel {
  final String header;
  final List<SettingSectionTileModel> settingsSectionTiles;

  SettingsSectionModel({
    required this.header,
    required this.settingsSectionTiles,
  });
}

class SettingSectionTileModel {
  final String title;
  final String description;
  final String icon;

  SettingSectionTileModel({
    required this.title,
    required this.description,
    required this.icon,
  });
}
