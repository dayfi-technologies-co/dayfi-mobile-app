/// Utility class for handling account number validation based on country and delivery method
class AccountNumberUtils {
  /// Account number configuration by country and delivery type
  /// Format: countryCode -> deliveryType -> AccountNumberInfo
  static const Map<String, Map<String, AccountNumberInfo>> countryAccountMap = {
    // Nigeria - Bank accounts are 10 digits
    'NG': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 10,
        description: '10-digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 10,
        description: '10-digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 10,
        maxLength: 10,
        description: '10-digit account number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 10,
        maxLength: 11,
        description: '10-11 digit mobile number',
      ),
    },
    // Ghana - Bank accounts are 13-16 digits, Mobile money is 9-10 digits
    'GH': {
      'bank': AccountNumberInfo(
        minLength: 13,
        maxLength: 16,
        description: '13-16 digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 13,
        maxLength: 16,
        description: '13-16 digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // Rwanda - Bank accounts 16 digits, Mobile money 9-10 digits
    'RW': {
      'bank': AccountNumberInfo(
        minLength: 16,
        maxLength: 16,
        description: '16-digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 16,
        maxLength: 16,
        description: '16-digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // Kenya - Bank accounts vary, Mobile money (M-Pesa) is 9-10 digits
    'KE': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 14,
        description: '10-14 digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 14,
        description: '10-14 digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // Uganda - Mobile money 9-10 digits
    'UG': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 16,
        description: '10-16 digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 16,
        description: '10-16 digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // Tanzania - Mobile money 9-10 digits
    'TZ': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 16,
        description: '10-16 digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 16,
        description: '10-16 digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // South Africa - Bank accounts 10-11 digits
    'ZA': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 11,
        description: '10-11 digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 11,
        description: '10-11 digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // Burkina Faso - Mobile money 8 digits
    'BF': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit mobile number',
      ),
    },
    // Benin - Mobile money 8 digits
    'BJ': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit mobile number',
      ),
    },
    // Botswana - 7-9 digits
    'BW': {
      'bank': AccountNumberInfo(
        minLength: 7,
        maxLength: 16,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 7,
        maxLength: 16,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 7,
        maxLength: 8,
        description: '7-8 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 7,
        maxLength: 8,
        description: '7-8 digit mobile number',
      ),
    },
    // DRC - Mobile money 9 digits
    'CD': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 20,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 20,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // Republic of Congo - Mobile money 9 digits
    'CG': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 20,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 20,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // Ivory Coast - Mobile money 8-10 digits
    'CI': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 8,
        maxLength: 10,
        description: '8-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 8,
        maxLength: 10,
        description: '8-10 digit mobile number',
      ),
    },
    // Cameroon - Mobile money 9 digits
    'CM': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 23,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 23,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 9,
        description: '9-digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 9,
        description: '9-digit mobile number',
      ),
    },
    // Gabon - Mobile money 8 digits
    'GA': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 23,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 23,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 7,
        maxLength: 8,
        description: '7-8 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 7,
        maxLength: 8,
        description: '7-8 digit mobile number',
      ),
    },
    // Malawi - Mobile money 9 digits
    'MW': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 16,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 16,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // Mali - Mobile money 8 digits
    'ML': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit mobile number',
      ),
    },
    // Senegal - Mobile money 9 digits
    'SN': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 9,
        description: '9-digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 9,
        description: '9-digit mobile number',
      ),
    },
    // Togo - Mobile money 8 digits
    'TG': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 24,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit mobile number',
      ),
    },
    // Zambia - Mobile money 9 digits
    'ZM': {
      'bank': AccountNumberInfo(
        minLength: 10,
        maxLength: 16,
        description: 'Account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 10,
        maxLength: 16,
        description: 'Account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 9,
        maxLength: 10,
        description: '9-10 digit mobile number',
      ),
    },
    // United States
    'US': {
      'bank': AccountNumberInfo(
        minLength: 8,
        maxLength: 17,
        description: '8-17 digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 8,
        maxLength: 17,
        description: '8-17 digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 10,
        maxLength: 10,
        description: '10-digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 10,
        maxLength: 10,
        description: '10-digit mobile number',
      ),
    },
    // United Kingdom
    'GB': {
      'bank': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 8,
        maxLength: 8,
        description: '8-digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 10,
        maxLength: 11,
        description: '10-11 digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 10,
        maxLength: 11,
        description: '10-11 digit mobile number',
      ),
    },
    // Canada
    'CA': {
      'bank': AccountNumberInfo(
        minLength: 7,
        maxLength: 12,
        description: '7-12 digit account number',
      ),
      'eft': AccountNumberInfo(
        minLength: 7,
        maxLength: 12,
        description: '7-12 digit account number',
      ),
      'p2p': AccountNumberInfo(
        minLength: 10,
        maxLength: 10,
        description: '10-digit number',
      ),
      'mobile_money': AccountNumberInfo(
        minLength: 10,
        maxLength: 10,
        description: '10-digit mobile number',
      ),
    },
  };

  /// Default account number info for unknown countries/delivery methods
  static const AccountNumberInfo defaultAccountInfo = AccountNumberInfo(
    minLength: 6,
    maxLength: 20,
    description: 'Account number',
  );

  /// Get account number info for a specific country and delivery method
  static AccountNumberInfo getAccountNumberInfo(
    String countryCode,
    String deliveryMethod,
  ) {
    final countryMap = countryAccountMap[countryCode.toUpperCase()];
    if (countryMap == null) return defaultAccountInfo;

    final normalizedMethod = _normalizeDeliveryMethod(deliveryMethod);
    return countryMap[normalizedMethod] ?? defaultAccountInfo;
  }

  /// Normalize delivery method to match our map keys
  static String _normalizeDeliveryMethod(String method) {
    switch (method.toLowerCase()) {
      case 'bank':
      case 'bank_transfer':
        return 'bank';
      case 'eft':
        return 'eft';
      case 'p2p':
      case 'peer_to_peer':
      case 'peer-to-peer':
        return 'p2p';
      case 'mobile_money':
      case 'momo':
      case 'mobilemoney':
        return 'mobile_money';
      default:
        return 'bank'; // Default to bank
    }
  }

  /// Validate account number for specific country and delivery method
  static String? validateAccountNumber(
    String accountNumber,
    String countryCode,
    String deliveryMethod,
  ) {
    final info = getAccountNumberInfo(countryCode, deliveryMethod);
    final cleanNumber = accountNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.isEmpty) {
      return 'Please enter account number';
    }

    if (cleanNumber.length < info.minLength) {
      if (info.minLength == info.maxLength) {
        return 'Account number must be exactly ${info.minLength} digits';
      }
      return 'Account number must be at least ${info.minLength} digits';
    }

    if (cleanNumber.length > info.maxLength) {
      if (info.minLength == info.maxLength) {
        return 'Account number must be exactly ${info.maxLength} digits';
      }
      return 'Account number must be at most ${info.maxLength} digits';
    }

    return null; // Valid
  }

  /// Check if account number is complete (at least minimum length)
  static bool isAccountNumberComplete(
    String accountNumber,
    String countryCode,
    String deliveryMethod,
  ) {
    final info = getAccountNumberInfo(countryCode, deliveryMethod);
    final cleanNumber = accountNumber.replaceAll(RegExp(r'[^\d]'), '');
    return cleanNumber.length >= info.minLength &&
        cleanNumber.length <= info.maxLength;
  }

  /// Get hint text for account number input
  static String getAccountNumberHint(
    String countryCode,
    String deliveryMethod,
  ) {
    final info = getAccountNumberInfo(countryCode, deliveryMethod);
    final isMobileMoney =
        _normalizeDeliveryMethod(deliveryMethod) == 'mobile_money';

    if (info.minLength == info.maxLength) {
      return 'Enter ${info.minLength}-digit ${isMobileMoney ? 'mobile number' : 'account number'}';
    }
    return 'Enter ${info.minLength}-${info.maxLength} digit ${isMobileMoney ? 'mobile number' : 'account number'}';
  }

  /// Get the max length for the text field
  static int getMaxLength(String countryCode, String deliveryMethod) {
    final info = getAccountNumberInfo(countryCode, deliveryMethod);
    return info.maxLength;
  }

  /// Get the min length for validation triggering
  static int getMinLength(String countryCode, String deliveryMethod) {
    final info = getAccountNumberInfo(countryCode, deliveryMethod);
    return info.minLength;
  }
}

/// Account number configuration info
class AccountNumberInfo {
  final int minLength;
  final int maxLength;
  final String description;

  const AccountNumberInfo({
    required this.minLength,
    required this.maxLength,
    required this.description,
  });
}
