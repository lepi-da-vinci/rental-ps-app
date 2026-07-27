import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../models/enums.dart';
import '../models/ps_unit.dart';
import 'api_config.dart';

/// Central HTTP Client Service for communicating with the Laravel Backend REST API.
class ApiService {
  /// Check if the Laravel Backend API server is online and reachable.
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(ApiConfig.timeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate Admin login credentials against Laravel `/login` API.
  static Future<Map<String, dynamic>?> loginAdmin(
      String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginEndpoint),
            headers: ApiConfig.headers,
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'] ?? '',
          'user': data['user'] ?? {},
        };
      }
    } catch (e) {
      debugPrint('ApiService.loginAdmin error: $e');
    }
    return null;
  }

  /// Fetch all active bookings from Laravel `/bookings` API.
  static Future<List<Booking>?> fetchBookings() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.bookingsEndpoint),
              headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body)['data'] ?? [];
        return jsonList.map((item) => _parseBookingFromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchBookings error: $e');
    }
    return null;
  }

  /// Send a new booking to Laravel `/bookings` API.
  static Future<bool> createBooking(Booking booking) async {
    try {
      final payload = {
        'id': booking.id,
        'customer_name': booking.customerName,
        'phone': booking.phone,
        'ps_type': booking.psType.name,
        'date': booking.date.toIso8601String().substring(0, 10),
        'time': booking.time,
        'duration_hours': booking.durationHours,
        'assigned_unit': booking.assignedUnit,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.bookingsEndpoint),
            headers: ApiConfig.headers,
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('ApiService.createBooking error: $e');
      return false;
    }
  }

  /// Send a Walk-in booking to Laravel `/bookings/walk-in` API.
  static Future<bool> createWalkIn({
    required ConsoleType baseType,
    required String unitLabel,
    required String playerName,
    required SessionDuration duration,
    required String startTime,
  }) async {
    try {
      final payload = {
        'customer_name': playerName,
        'ps_type': baseType.name,
        'unit_label': unitLabel,
        'duration_hours': duration.hours,
        'start_time': startTime,
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.walkInEndpoint),
            headers: ApiConfig.headers,
            body: jsonEncode(payload),
          )
          .timeout(ApiConfig.timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('ApiService.createWalkIn error: $e');
      return false;
    }
  }

  /// Delete a booking on Laravel `/bookings/{id}` API.
  static Future<bool> deleteBooking(String bookingId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.bookingsEndpoint}/$bookingId'),
            headers: ApiConfig.headers,
          )
          .timeout(ApiConfig.timeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('ApiService.deleteBooking error: $e');
      return false;
    }
  }

  /// Fetch live unit statuses from Laravel `/units/status` API.
  static Future<List<UnitStatus>?> fetchLiveUnits() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.unitStatusEndpoint),
              headers: ApiConfig.headers)
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body)['data'] ?? [];
        return jsonList.map((item) => _parseUnitStatusFromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchLiveUnits error: $e');
    }
    return null;
  }

  /// Helper to convert JSON map from Laravel API to [Booking] model.
  static Booking _parseBookingFromJson(Map<String, dynamic> json) {
    ConsoleType psType = ConsoleType.ps4;
    try {
      psType = ConsoleType.values.firstWhere(
        (e) => e.name == json['ps_type'] || e.displayName == json['ps_type'],
        orElse: () => ConsoleType.fromDisplayName(json['ps_type'] ?? 'PS4'),
      );
    } catch (_) {}

    int durHours = json['duration_hours'] ?? 1;
    SessionDuration duration = SessionDuration.values.firstWhere(
      (d) => d.hours == durHours,
      orElse: () => SessionDuration.jam1,
    );

    return Booking(
      id: json['id'] ?? 'BK-API',
      customerName: json['customer_name'] ?? 'Pelanggan',
      phone: json['phone'] ?? '-',
      psType: psType,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '08:00',
      duration: duration,
      assignedUnit: json['assigned_unit'] ?? '',
    );
  }

  /// Helper to convert JSON map from Laravel API to [UnitStatus] model.
  static UnitStatus _parseUnitStatusFromJson(Map<String, dynamic> json) {
    ConsoleType psType = ConsoleType.ps4;
    try {
      psType = ConsoleType.values.firstWhere(
        (e) => e.name == json['ps_type'],
        orElse: () => ConsoleType.fromDisplayName(json['ps_type'] ?? 'PS4'),
      );
    } catch (_) {}

    return UnitStatus(
      unitId: json['unit_id'] ?? 'UNIT-01',
      psType: psType,
      label: json['label'] ?? 'Unit 1',
      isAvailable: json['is_available'] ?? true,
      playerName: json['player_name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isWalkIn: json['is_walk_in'] ?? false,
    );
  }
}
