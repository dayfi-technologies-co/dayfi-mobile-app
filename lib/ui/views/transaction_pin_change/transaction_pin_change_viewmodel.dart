import 'package:flutter/material.dart';
import 'package:dayfi/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class TransactionPinChangeViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();

  final TextEditingController pinTextEditingController =
      TextEditingController();
}
