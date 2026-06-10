import 'package:dayfi/features/dayearn/constants/dayearn_copy.dart';

class DayEarnFormValidation {
  DayEarnFormValidation._();

  static String? depositAmount(
    String? value, {
    double? walletBalance,
  }) {
    if (value == null || value.trim().isEmpty) {
      return DayEarnCopy.amountRequired;
    }

    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return DayEarnCopy.amountInvalid;
    }

    if (walletBalance != null && amount > walletBalance) {
      return DayEarnCopy.insufficientWalletBalance;
    }

    return null;
  }

  static String? withdrawAmount(
    String? value, {
    required double potBalance,
    required bool withdrawAll,
  }) {
    if (withdrawAll) return null;

    if (value == null || value.trim().isEmpty) {
      return DayEarnCopy.amountRequired;
    }

    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return DayEarnCopy.amountInvalid;
    }

    if (amount > potBalance) {
      return DayEarnCopy.insufficientPotBalance;
    }

    return null;
  }
}
