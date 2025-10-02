import 'package:flutter/services.dart';

/// Custom TextInputFormatter that formats numbers with commas as user types
/// Allows input like: 1,234,567.89
class NumberWithCommasFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters except decimal point
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    
    // If user is just typing digits without decimal, don't force decimal format
    if (!digitsOnly.contains('.') && digitsOnly.isNotEmpty) {
      // Just add commas to the integer part
      String formatted = _addCommas(digitsOnly);
      
      // Calculate cursor position for integer-only input
      int cursorPosition = _calculateCursorPositionSimple(
        oldValue.text,
        newValue.text,
        formatted,
        newValue.selection.baseOffset,
      );

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: cursorPosition),
      );
    }
    
    // Handle decimal input
    List<String> parts = digitsOnly.split('.');
    if (parts.length > 2) {
      // Multiple decimal points - keep only the first one
      digitsOnly = '${parts[0]}.${parts.sublist(1).join('')}';
      parts = digitsOnly.split('.');
    }
    
    // Limit decimal places to 2
    if (parts.length == 2 && parts[1].length > 2) {
      digitsOnly = '${parts[0]}.${parts[1].substring(0, 2)}';
    }

    // Format with commas
    String formatted = _addCommas(digitsOnly);

    // Calculate cursor position
    int cursorPosition = _calculateCursorPositionSimple(
      oldValue.text,
      newValue.text,
      formatted,
      newValue.selection.baseOffset,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  /// Add commas to number string
  String _addCommas(String numberString) {
    if (numberString.isEmpty) return '';

    List<String> parts = numberString.split('.');
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

    // Return with decimal part if it exists
    return decimalPart.isEmpty ? formattedInteger : '$formattedInteger.$decimalPart';
  }


  /// Simplified cursor position calculation
  int _calculateCursorPositionSimple(
    String oldText,
    String newText,
    String formattedText,
    int originalCursorPosition,
  ) {
    // If user is at the end, put cursor at the end
    if (originalCursorPosition >= newText.length) {
      return formattedText.length;
    }

    // Count digits before cursor in the new text
    int digitsBeforeCursor = 0;
    for (int i = 0; i < originalCursorPosition && i < newText.length; i++) {
      if (RegExp(r'\d').hasMatch(newText[i])) {
        digitsBeforeCursor++;
      }
    }

    // Find corresponding position in formatted text
    int currentDigits = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (RegExp(r'\d').hasMatch(formattedText[i])) {
        currentDigits++;
        if (currentDigits >= digitsBeforeCursor) {
          return (i + 1).clamp(0, formattedText.length);
        }
      }
    }

    return formattedText.length;
  }
}

/// Utility class for number formatting operations
class NumberFormatterUtils {
  /// Remove commas from a formatted number string for calculations
  static String removeCommas(String formattedNumber) {
    return formattedNumber.replaceAll(',', '');
  }

  /// Format a plain number string with commas
  static String addCommas(String numberString) {
    if (numberString.isEmpty) return '';
    
    // Remove existing commas
    String clean = removeCommas(numberString);
    
    // Validate it's a number
    if (double.tryParse(clean) == null) return numberString;
    
    List<String> parts = clean.split('.');
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

    return decimalPart.isEmpty ? formattedInteger : '$formattedInteger.$decimalPart';
  }
}
