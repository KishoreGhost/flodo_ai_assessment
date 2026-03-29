import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get apiBaseUrl {
    // .env override wins if non-empty
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) return envUrl;

    // Web, Windows desktop, macOS, iOS simulator: localhost works
    // Android emulator: set API_BASE_URL=http://10.0.2.2:8000 in .env
    return 'http://localhost:8000';
  }
}
