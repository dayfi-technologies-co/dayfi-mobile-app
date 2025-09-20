import 'package:intl/intl.dart';

class AmountFormatter {
  /// Formats a number string to include thousand separators
  /// Example: "75000000" becomes "75,000,000"
  static String formatAmount(String amount) {
    // Convert string to double
    double? number = double.tryParse(amount);
    if (number == null) return amount; // Return original if not a valid number

    // Create number formatter
    final formatter = NumberFormat("#,##0", "en_US");

    return formatter.format(number);
  }

  /// Formats a number to include thousand separators
  /// Example: 75000000 becomes "75,000,000"
  static String formatNumber(num number) {
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(number);
  }

  /// Formats a number with currency symbol and thousand separators
  /// Example: 75000000 becomes "NGN75,000,000"
  static String formatCurrency(num number, {String symbol = 'NGN'}) {
    final formatter = NumberFormat("#,##0", "en_US");
    return '$symbol${formatter.format(number)}';
  }

  /// Formats a decimal number with specified decimal places
  /// Example: 75000000.123 with 2 decimal places becomes "75,000,000.12"
  static String formatDecimal(num number, {int decimalPlaces = 2}) {
    final formatter = NumberFormat("#,##0.${'0' * decimalPlaces}", "en_US");
    return formatter.format(number);
  }
}
