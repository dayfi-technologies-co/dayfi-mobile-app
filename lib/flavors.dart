enum Flavor { dev, pilot, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Dayfi App';
      case Flavor.pilot:
        return 'Dayfi App';
      case Flavor.prod:
        return 'Dayfi App';
    }
  }

  /// Dev API:
  /// - **Railway / HTTPS:** `--dart-define=DAYFI_API_BASE_URL=https://…up.railway.app/api/v1` (or use **pilot** / **prod** flavor — base URL is set in this file).
  /// - **Local:** `--dart-define=DAYFI_API_HOST=127.0.0.1` and `DAYFI_API_PORT=3000` (phone on LAN: use Mac IP, not x.x.x.1).
  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        const remoteBase = String.fromEnvironment('DAYFI_API_BASE_URL', defaultValue: '');
        if (remoteBase.isNotEmpty) {
          final trimmed = remoteBase.replaceAll(RegExp(r'/+$'), '');
          return trimmed.endsWith('/api/v1') ? trimmed : '$trimmed/api/v1';
        }
        const host = String.fromEnvironment('DAYFI_API_HOST', defaultValue: '127.0.0.1');
        const port = String.fromEnvironment('DAYFI_API_PORT', defaultValue: '3000');
        return 'http://$host:$port/api/v1';
      case Flavor.pilot:
        return "https://dayfibackend-production.up.railway.app/api/v1";
      case Flavor.prod:
        return "https://dayfibackend-production.up.railway.app/api/v1";
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
