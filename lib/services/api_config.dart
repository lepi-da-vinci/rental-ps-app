import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Centralized REST API Configuration for Laravel Backend integration.
class ApiConfig {
  /// Base URL of the Laravel API.
  /// Automatically uses 10.0.2.2 for Android emulator and localhost for Web/Desktop.
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    } catch (_) {}
    return 'http://localhost:8000/api';
  }

  static String _customBaseUrl = '';

  /// Active base URL. Can be dynamically updated at runtime (e.g. Cloud domain or Ngrok HTTPS URL).
  static String get baseUrl {
    if (_customBaseUrl.trim().isNotEmpty) return _customBaseUrl.trim();
    return defaultBaseUrl;
  }

  /// Sets a custom API URL (e.g. 'https://my-laravel-api.up.railway.app/api' or 'https://xxxx.ngrok-free.app/api')
  static void setCustomBaseUrl(String url) {
    String cleanUrl = url.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    if (!cleanUrl.endsWith('/api') && !cleanUrl.contains('/api')) {
      cleanUrl = '$cleanUrl/api';
    }
    _customBaseUrl = cleanUrl;
  }

  /// Default HTTP timeout duration before falling back to local simulation mode.
  static const Duration timeout = Duration(seconds: 5);

  /// Standard HTTP headers for JSON payloads.
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Headers with Bearer Token authentication.
  static Map<String, String> authHeaders(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };

  // ── API Endpoints ──
  static String get loginEndpoint => '$baseUrl/login';
  static String get unitsEndpoint => '$baseUrl/units';
  static String get unitStatusEndpoint => '$baseUrl/units/status';
  static String get bookingsEndpoint => '$baseUrl/bookings';
  static String get walkInEndpoint => '$baseUrl/bookings/walk-in';
  static String get gamesEndpoint => '$baseUrl/games';
  static String get pricePackagesEndpoint => '$baseUrl/price-packages';
  static String dailyRevenueEndpoint(String dateStr) =>
      '$baseUrl/revenue/daily?date=$dateStr';
  static String monthlyRevenueEndpoint(int year, int month) =>
      '$baseUrl/revenue/monthly?year=$year&month=$month';
}
