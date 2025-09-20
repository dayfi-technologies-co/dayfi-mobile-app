import 'dart:convert';
import 'dart:developer';

import 'package:dayfi/data/models/user_model.dart';
import 'package:dayfi/data/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class PersonaliseCardViewModel extends BaseViewModel {
  Color _selectedColor = Color.fromARGB(255, 12, 2, 29);
  Color get selectedColor => _selectedColor;

  String _cardHolderName = '';
  String get cardHolderName => _cardHolderName;

  final SecureStorageService _storageService = SecureStorageService();
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  User? user;

  Future<void> loadUser() async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      final userJson = await _storageService.read('user');
      log('Stored user JSON: $userJson');
      if (userJson != null) {
        user = User.fromJson(json.decode(userJson));
        log('User loaded: ${user!.userId}');
        if (user!.userId.isEmpty) {
          log('Error: userId is empty after parsing');
          _hasError = true;
        } else {
          // Set default cardholder name from user
          _cardHolderName = '${user!.firstName} ${user!.lastName}';
        }
      } else {
        log('No user data found in secure storage');
        _hasError = true;
      }
    } catch (e, stackTrace) {
      log('Error loading user: $e', stackTrace: stackTrace);
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateCardColor(Color color) {
    _selectedColor = color;
    notifyListeners();
  }

  void updateCardHolderName(String name) {
    _cardHolderName = name;
    notifyListeners();
  }

  // PIN Logic
  List<String?> pin = List.generate(4, (_) => null);
  bool get isPinComplete => pin.every((p) => p != null);

  void addPin(String value) {
    for (int i = 0; i < pin.length; i++) {
      if (pin[i] == null) {
        pin[i] = value;
        notifyListeners();
        break;
      }
    }
  }

  void removePin() {
    for (int i = pin.length - 1; i >= 0; i--) {
      if (pin[i] != null) {
        pin[i] = null;
        notifyListeners();
        break;
      }
    }
  }
}