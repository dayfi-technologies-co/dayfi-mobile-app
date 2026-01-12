
class StringUtils {

  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }


  static String toTitleCase(String text) {
    if (isNullOrEmpty(text)) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  static String removeWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), '');
  }

  /// Format number with commas for better readability
  /// Example: 5555000000.00 -> 5,555,000,000.00
  static String formatNumberWithCommas(String numberString) {
    if (isNullOrEmpty(numberString)) return '';
    
    // Remove any existing commas and whitespace
    String cleanNumber = numberString.replaceAll(RegExp(r'[,\s]'), '');
    
    // Try to parse as double to validate
    final double? number = double.tryParse(cleanNumber);
    if (number == null) return numberString;
    
    // Split into integer and decimal parts
    List<String> parts = cleanNumber.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Add commas to integer part
    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += ',';
      }
      formattedInteger += integerPart[i];
    }
    
    // Only add decimal part if it exists in the original input
    if (decimalPart.isNotEmpty) {
      // Ensure decimal part has at most 2 digits
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }
      return '$formattedInteger.$decimalPart';
    }
    
    return formattedInteger;
  }

  /// Remove commas from formatted number for calculations
  /// Example: 5,555,000,000.00 -> 5555000000.00
  static String removeCommasFromNumber(String formattedNumber) {
    return formattedNumber.replaceAll(',', '');
  }

  /// Format currency amount with symbol and commas
  /// Example: formatCurrency('5555000000.00', 'NGN') -> ₦5,555,000,000.00
  static String formatCurrency(String amount, String currencyCode) {
    if (isNullOrEmpty(amount)) return '';
    
    String formattedAmount = formatNumberWithCommas(amount);
    
    // Ensure we have decimal places for currency display
    if (!formattedAmount.contains('.')) {
      formattedAmount += '.00';
    } else {
      // Ensure exactly 2 decimal places for currency
      List<String> parts = formattedAmount.split('.');
      if (parts.length == 2) {
        String decimalPart = parts[1];
        if (decimalPart.length == 1) {
          formattedAmount += '0';
        }
      }
    }
    
    switch (currencyCode.toUpperCase()) {
      case 'NGN':
        return '₦$formattedAmount';
      case 'USD':
        return '\$$formattedAmount';
      case 'EUR':
        return '€$formattedAmount';
      case 'GBP':
        return '£$formattedAmount';
      default:
        return '$currencyCode $formattedAmount';
    }
  }
}
