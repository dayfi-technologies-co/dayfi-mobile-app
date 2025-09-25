enum Flavor { dev, pilot, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Dayfi Test';
      case Flavor.pilot:
        return 'Dayfi Pilot';
      case Flavor.prod:
        return 'Dayfi';
    }
  }

  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return "https://api-dev.dayfi.com/gateway";
      case Flavor.pilot:
        return "https://api-pilot.dayfi.com/gateway";
      case Flavor.prod:
        return "https://api.dayfi.com/gateway";
    }
  }

  //app short link
  static String get shareTheVibeBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return "https://shorturl.at/d1aBh";
      case Flavor.pilot:
        return "https://shorturl.at/6n5c6";
      case Flavor.prod:
        return "https://shorturl.at/6n5c6";
    }
  }

  static String get joinCommunityLinkUrl {
    return "https://dayfi.com/community";
  }

  static String get camsBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return "https://api-dev.dayfi.com/cams";
      case Flavor.pilot:
        return "https://api-pilot.dayfi.com/cams";
      case Flavor.prod:
        return "https://api.dayfi.com/cams";
    }
  }

  static String get appVersion {
    switch (appFlavor) {
      case Flavor.dev:
        return "3.0";
      case Flavor.pilot:
        return "3.0.8";
      case Flavor.prod:
        return "3.2.0";
    }
  }

  static String get cBankingUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return "https://api-dev.dayfi.com/community/api/v1/banking";
      case Flavor.pilot:
        return "https://api-pilot.dayfi.com/community/api/v1/banking";
      case Flavor.prod:
        return "https://api.dayfi.com/community/api/v1/banking";
    }
  }
}
