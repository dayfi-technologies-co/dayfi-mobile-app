import 'package:dayfi/app/app.locator.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PaymentSetupViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();

  final currencyTextController = TextEditingController(
    text: "NGN",
  );

  bool showCurrencyOptions = false;
  String? initialValue;
  void Function(String)? onValueChanged;
  String previousText = '';
  int previousCursorPosition = 0;

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    try {
      final amount = double.parse(value.replaceAll(',', ''));
      if (amount <= 99) {
        return 'Amount must be greater than 99';
      }
      if (amount > 300000) {
        return 'Amount must be less than 300,000';
      }
      return null; // Valid input
    } catch (e) {
      return 'Please enter a valid number';
    }
  }

  bool isAmountValid(String value) {
    if (value.isEmpty) return false;
    try {
      final amount = double.parse(value.replaceAll(',', ''));
      return amount > 99 && amount <= 300000;
    } catch (e) {
      return false;
    }
  }

  final List<CurrencyModel> currencies = [
    CurrencyModel(
      name: "NGN",
      icon: "assets/images/nigeria.png",
    ),
    CurrencyModel(
      name: 'USD',
      icon: "assets/images/united-states.png",
    ),
    CurrencyModel(
      name: "GBP",
      icon: "assets/images/united-kingdom.png",
    ),
    CurrencyModel(
      name: "EUR",
      icon: "assets/images/european-union.png",
    ),
  ];
}

class CurrencyModel {
  final String name;
  final String icon;

  CurrencyModel({
    required this.icon,
    required this.name,
  });
}
