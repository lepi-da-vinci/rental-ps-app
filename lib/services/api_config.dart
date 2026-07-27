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

  /// Active base URL. Can be changed at runtime if connected to a local WiFi IP or production domain.
  static String baseUrl = defaultBaseUrl;

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
