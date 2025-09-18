enum Flavor { dev, pilot, prod }

class F {
  static late final Flavor appFlavor;

  static void init({Flavor? override}) {
    if (override != null) {
      appFlavor = override;
      return;
    }
    final flavorString = const String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    switch (flavorString.toLowerCase()) {
      case 'dev':
        appFlavor = Flavor.dev;
        break;
      case 'pilot':
        appFlavor = Flavor.pilot;
        break;
      case 'prod':
      case 'production':
        appFlavor = Flavor.prod;
        break;
      default:
        appFlavor = Flavor.dev;
    }
  }

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Dayfi Dev';
      case Flavor.pilot:
        return 'Dayfi Pilot';
      case Flavor.prod:
        return 'Dayfi';
    }
  }

  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return 'https://api.dev.dayfi.app';
      case Flavor.pilot:
        return 'https://api.pilot.dayfi.app';
      case Flavor.prod:
        return 'https://api.dayfi.app';
    }
  }

  static String get shareTheVibeBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return 'https://short.dayfi.app/dev';
      case Flavor.pilot:
        return 'https://short.dayfi.app/pilot';
      case Flavor.prod:
        return 'https://short.dayfi.app/app';
    }
  }

  static String get joinCommunityLinkUrl {
    return 'https://dayfi.app/community';
  }

  static String get camsBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return 'https://cams.dev.dayfi.app';
      case Flavor.pilot:
        return 'https://cams.pilot.dayfi.app';
      case Flavor.prod:
        return 'https://cams.dayfi.app';
    }
  }

  static String get appVersion {
    switch (appFlavor) {
      case Flavor.dev:
        return '0.1.0-dev';
      case Flavor.pilot:
        return '0.1.0-rc';
      case Flavor.prod:
        return '0.1.0';
    }
  }

  static String get cBankingUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return 'https://cbanking.dev.dayfi.app/api/v1';
      case Flavor.pilot:
        return 'https://cbanking.pilot.dayfi.app/api/v1';
      case Flavor.prod:
        return 'https://cbanking.dayfi.app/api/v1';
    }
  }
}


