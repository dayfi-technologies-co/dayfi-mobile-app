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
    
    // Check if the input starts with a dot (e.g., ".88")
    bool startsWithDot = digitsOnly.startsWith('.');
    
    // Remove leading zeros from integer part (but allow "0." or just "0")
    if (!startsWithDot && digitsOnly.isNotEmpty) {
      List<String> parts = digitsOnly.split('.');
      if (parts.isNotEmpty && parts[0].length > 1 && parts[0].startsWith('0')) {
        // Remove leading zeros but keep at least one digit
        String integerPart = parts[0].replaceFirst(RegExp(r'^0+'), '');
        if (integerPart.isEmpty) {
          integerPart = '0';
        }
        digitsOnly = parts.length > 1 ? '$integerPart.${parts.sublist(1).join('')}' : integerPart;
      }
    }
    
    // If user is just typing digits without decimal, don't force decimal format
    if (!digitsOnly.contains('.')) {
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
      // Update startsWithDot after reconstruction
      startsWithDot = digitsOnly.startsWith('.');
    }
    
    // Limit decimal places to 2
    if (parts.length == 2 && parts[1].length > 2) {
      digitsOnly = startsWithDot 
          ? '.${parts[1].substring(0, 2)}'
          : '${parts[0]}.${parts[1].substring(0, 2)}';
    }

    // Format with commas (preserving leading dot if present)
    String formatted = _addCommas(digitsOnly, startsWithDot);

    // Calculate cursor position - ensure decimal point is visible immediately
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
  String _addCommas(String numberString, [bool startsWithDot = false]) {
    if (numberString.isEmpty) return '';

    // Handle case where input starts with dot (e.g., ".88")
    if (startsWithDot && numberString.startsWith('.')) {
      String decimalPart = numberString.substring(1);
      // Limit decimal places to 2
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }
      return '.$decimalPart';
    }

    List<String> parts = numberString.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    bool hasDecimalPoint = numberString.contains('.');

    // Add commas to integer part
    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += ',';
      }
      formattedInteger += integerPart[i];
    }

    // Return with decimal part if it exists or if there's a decimal point (even if empty decimal part)
    if (hasDecimalPoint) {
      // Limit decimal places to 2
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }
      return '$formattedInteger.$decimalPart';
    }
    return formattedInteger;
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

    // Check if user just typed a decimal point
    bool justTypedDecimal = newText.length > oldText.length && 
        newText.contains('.') && 
        !oldText.contains('.');

    // Count digits before cursor in the new text (excluding commas and decimal points)
    int digitsBeforeCursor = 0;
    int decimalPointIndex = -1;
    bool cursorAtDecimalPoint = false;
    for (int i = 0; i < originalCursorPosition && i < newText.length; i++) {
      if (newText[i] == '.') {
        decimalPointIndex = i;
        // Check if cursor is right at the decimal point
        if (i == originalCursorPosition - 1 || i == originalCursorPosition) {
          cursorAtDecimalPoint = true;
        }
      } else if (RegExp(r'\d').hasMatch(newText[i])) {
        digitsBeforeCursor++;
      }
    }

    // If user just typed decimal point, position cursor right after it
    if (justTypedDecimal && formattedText.contains('.')) {
      int dotIndex = formattedText.indexOf('.');
      return (dotIndex + 1).clamp(0, formattedText.length);
    }

    // Find corresponding position in formatted text
    int currentDigits = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i] == '.') {
        // If cursor was at or right after the decimal point in original text
        if (cursorAtDecimalPoint || 
            (decimalPointIndex != -1 && 
            originalCursorPosition >= decimalPointIndex && 
            originalCursorPosition <= decimalPointIndex + 1 &&
            currentDigits == digitsBeforeCursor)) {
          return (i + 1).clamp(0, formattedText.length);
        }
      } else if (RegExp(r'\d').hasMatch(formattedText[i])) {
        currentDigits++;
        if (currentDigits >= digitsBeforeCursor) {
          // Check if we should position before or after this digit
          if (currentDigits == digitsBeforeCursor && 
              decimalPointIndex == -1 && 
              originalCursorPosition < newText.length &&
              RegExp(r'\d').hasMatch(newText[originalCursorPosition])) {
            return (i + 1).clamp(0, formattedText.length);
          }
          if (currentDigits > digitsBeforeCursor) {
            return i.clamp(0, formattedText.length);
          }
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
