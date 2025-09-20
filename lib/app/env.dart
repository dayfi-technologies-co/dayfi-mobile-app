import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static const String dev = 'dev';
  static const String staging = 'staging';
  static const String prod = 'prod';

  String get envFile {
    const env = String.fromEnvironment('ENV', defaultValue: dev);
    switch (env) {
      case prod:
        return '.env.prod';
      case staging:
        return '.env.staging';
      default:
        return '.env.dev';
    }
  }

  String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'https://dayfi-app-31eb033892cf.herokuapp.com/api/v1';
}
