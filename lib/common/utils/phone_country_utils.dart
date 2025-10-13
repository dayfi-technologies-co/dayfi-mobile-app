class PhoneCountryUtils {
  // Country code mapping based on the countries in your app
  static const Map<String, CountryPhoneInfo> countryPhoneMap = {
    'NG': CountryPhoneInfo(countryCode: '+234', name: 'Nigeria', maxLength: 10, minLength: 10),
    'GH': CountryPhoneInfo(countryCode: '+233', name: 'Ghana', maxLength: 9, minLength: 9),
    'RW': CountryPhoneInfo(countryCode: '+250', name: 'Rwanda', maxLength: 9, minLength: 9),
    'KE': CountryPhoneInfo(countryCode: '+254', name: 'Kenya', maxLength: 9, minLength: 9),
    'UG': CountryPhoneInfo(countryCode: '+256', name: 'Uganda', maxLength: 9, minLength: 9),
    'TZ': CountryPhoneInfo(countryCode: '+255', name: 'Tanzania', maxLength: 9, minLength: 9),
    'ZA': CountryPhoneInfo(countryCode: '+27', name: 'South Africa', maxLength: 9, minLength: 9),
    'BF': CountryPhoneInfo(countryCode: '+226', name: 'Burkina Faso', maxLength: 8, minLength: 8),
    'BJ': CountryPhoneInfo(countryCode: '+229', name: 'Benin', maxLength: 8, minLength: 8),
    'BW': CountryPhoneInfo(countryCode: '+267', name: 'Botswana', maxLength: 7, minLength: 7),
    'CD': CountryPhoneInfo(countryCode: '+243', name: 'Democratic Republic of Congo', maxLength: 9, minLength: 9),
    'CG': CountryPhoneInfo(countryCode: '+242', name: 'Republic of the Congo', maxLength: 9, minLength: 9),
    'CI': CountryPhoneInfo(countryCode: '+225', name: 'Ivory Coast', maxLength: 8, minLength: 8),
    'CM': CountryPhoneInfo(countryCode: '+237', name: 'Cameroon', maxLength: 9, minLength: 9),
    'GA': CountryPhoneInfo(countryCode: '+241', name: 'Gabon', maxLength: 8, minLength: 8),
    'MW': CountryPhoneInfo(countryCode: '+265', name: 'Malawi', maxLength: 9, minLength: 9),
    'SN': CountryPhoneInfo(countryCode: '+221', name: 'Senegal', maxLength: 9, minLength: 9),
    'TG': CountryPhoneInfo(countryCode: '+228', name: 'Togo', maxLength: 8, minLength: 8),
    'ZM': CountryPhoneInfo(countryCode: '+260', name: 'Zambia', maxLength: 9, minLength: 9),
    'US': CountryPhoneInfo(countryCode: '+1', name: 'United States', maxLength: 10, minLength: 10),
    'GB': CountryPhoneInfo(countryCode: '+44', name: 'United Kingdom', maxLength: 10, minLength: 10),
    'CA': CountryPhoneInfo(countryCode: '+1', name: 'Canada', maxLength: 10, minLength: 10),
  };

  /// Get country phone info by country code
  static CountryPhoneInfo? getCountryPhoneInfo(String countryCode) {
    return countryPhoneMap[countryCode.toUpperCase()];
  }

  /// Format phone number with country code
  static String formatPhoneNumber(String phoneNumber, String countryCode) {
    final countryInfo = getCountryPhoneInfo(countryCode);
    if (countryInfo == null) return phoneNumber;

    // Remove any existing country code or formatting
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Remove country code if it's already there
    final countryCodeDigits = countryInfo.countryCode.replaceAll('+', '');
    if (cleanNumber.startsWith(countryCodeDigits)) {
      cleanNumber = cleanNumber.substring(countryCodeDigits.length);
    }

    // Return formatted number with country code
    return '${countryInfo.countryCode}$cleanNumber';
  }

  /// Validate phone number for specific country
  static String? validatePhoneNumber(String phoneNumber, String countryCode) {
    final countryInfo = getCountryPhoneInfo(countryCode);
    if (countryInfo == null) return 'Invalid country code';

    // Remove any existing country code or formatting
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Remove country code if it's already there
    final countryCodeDigits = countryInfo.countryCode.replaceAll('+', '');
    if (cleanNumber.startsWith(countryCodeDigits)) {
      cleanNumber = cleanNumber.substring(countryCodeDigits.length);
    }

    if (cleanNumber.isEmpty) {
      return 'Phone number is required';
    }

    if (cleanNumber.length < countryInfo.minLength) {
      return 'Phone number must be at least ${countryInfo.minLength} digits';
    }

    if (cleanNumber.length > countryInfo.maxLength) {
      return 'Phone number must be at most ${countryInfo.maxLength} digits';
    }

    return null; // Valid
  }

  /// Extract country code from formatted phone number
  static String? extractCountryCode(String formattedPhoneNumber) {
    for (final entry in countryPhoneMap.entries) {
      if (formattedPhoneNumber.startsWith(entry.value.countryCode)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get display text for phone input (country code + placeholder)
  static String getPhoneInputDisplayText(String countryCode) {
    final countryInfo = getCountryPhoneInfo(countryCode);
    if (countryInfo == null) return 'Enter phone number';

    return '${countryInfo.countryCode} ${'X' * countryInfo.maxLength}';
  }

  /// Get placeholder text for phone input
  static String getPhoneInputPlaceholder(String countryCode) {
    final countryInfo = getCountryPhoneInfo(countryCode);
    if (countryInfo == null) return 'Enter phone number';

    return '${countryInfo.countryCode} ${'X' * countryInfo.maxLength}';
  }
}

class CountryPhoneInfo {
  final String countryCode;
  final String name;
  final int maxLength;
  final int minLength;

  const CountryPhoneInfo({
    required this.countryCode,
    required this.name,
    required this.maxLength,
    required this.minLength,
  });
}
