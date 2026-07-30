import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../models/enums.dart';
import '../models/customer.dart';
import '../models/ps_unit.dart';
import '../data/dummy_data.dart';
import '../data/dummy_revenue.dart';
import '../utils/time_helpers.dart';
import '../services/api_service.dart';

/// Manages all booking-related state: CRUD, scheduling, live unit status, and API sync.
class BookingProvider extends ChangeNotifier {
  static const String _storageKey = 'local_bookings_v1';
  final List<Booking> _bookings = [];
  final List<UnitStatus> _templateUnits = getDummyUnitStatus();
  DateTime _now = DateTime.now();

  bool _isApiConnected = false;
  bool _isSyncing = false;

  bool get isApiConnected => _isApiConnected;
  bool get isSyncing => _isSyncing;

  BookingProvider() {
    _initStorageAndSync();
  }

  Future<void> _initStorageAndSync() async {
    await _loadLocalBookings();
    if (_bookings.isEmpty) {
      _bookings.addAll(generateMonthlyBookings(_now));
      await _saveLocalBookings();
    }
    notifyListeners();
    await syncWithApi();
  }

  Future<void> _loadLocalBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _bookings.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _bookings.add(Booking.fromJson(item));
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading local bookings: $e');
    }
  }

  Future<void> _saveLocalBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_bookings.map((b) => b.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving local bookings: $e');
    }
  }

  /// Sync data with Laravel API backend if available.
  Future<void> syncWithApi() async {
    _isSyncing = true;
    notifyListeners();

    try {
      final isOnline = await ApiService.checkServerHealth();
      _isApiConnected = isOnline;

      if (isOnline) {
        final apiBookings = await ApiService.fetchBookings();
        if (apiBookings != null && apiBookings.isNotEmpty) {
          // Smart Merge: Don't wipe out local bookings that aren't synced yet
          for (final apiB in apiBookings) {
            final idx = _bookings.indexWhere((b) => b.id == apiB.id);
            if (idx != -1) {
              _bookings[idx] = apiB;
            } else {
              _bookings.add(apiB);
            }
          }
          await _saveLocalBookings();
        }
      }
    } catch (e) {
      _isApiConnected = false;
      debugPrint('BookingProvider.syncWithApi error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Called by ProxyProvider when [ClockService] ticks (every second).
  void updateClock(DateTime newNow) {
    final secondChanged = _now.second != newNow.second;
    _now = newNow;

    // Fast Polling: Sync with API every 10 seconds to keep data live
    if (secondChanged && newNow.second % 10 == 0 && _isApiConnected && !_isSyncing) {
      syncWithApi();
    }
  }

  DateTime get now => _now;
  List<Booking> get bookings => List.unmodifiable(_bookings);
  int get bookingCount => _bookings.length;

  // ════════════════════════════════════════════════════════
  //  CUSTOMER HELPERS
  // ════════════════════════════════════════════════════════

  /// Extracts unique customers from the booking history and aggregates their stats.
  List<Customer> get customers {
    final map = <String, Customer>{};

    for (final b in _bookings) {
      final key = b.customerName.toLowerCase().trim();
      if (key.isEmpty) continue;

      // Estimate spent
      final match = dummyPricePackages.where((p) => p.name == b.psType.bookingDisplayName).toList();
      int spent = 0;
      if (match.isNotEmpty) {
        spent = match.first.prices.first.price * b.durationHours;
      }

      if (map.containsKey(key)) {
        final existing = map[key]!;
        map[key] = Customer(
          name: existing.name,
          phone: b.phone.isNotEmpty ? b.phone : existing.phone,
          totalBookings: existing.totalBookings + 1,
          totalSpent: existing.totalSpent + spent,
          lastVisit: b.date.isAfter(existing.lastVisit ?? DateTime(2000)) ? b.date : existing.lastVisit,
          favoriteConsole: existing.favoriteConsole,
        );
      } else {
        map[key] = Customer(
          name: b.customerName.trim(),
          phone: b.phone.trim(),
          totalBookings: 1,
          totalSpent: spent,
          lastVisit: b.date,
          favoriteConsole: b.psType,
        );
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => b.totalBookings.compareTo(a.totalBookings));
    return list;
  }

  // ════════════════════════════════════════════════════════
  //  SESSION TIMER HELPERS
  // ════════════════════════════════════════════════════════

  DateTime _getBookingStartDateTime(Booking b) {
    final parts = b.time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return DateTime(b.date.year, b.date.month, b.date.day, hour, minute);
  }

  DateTime _getBookingEndDateTime(Booking b) {
    final start = _getBookingStartDateTime(b);
    return start.add(Duration(hours: b.durationHours));
  }

  /// Returns the remaining seconds for a unit's active session.
  /// Negative values mean the session is overtime.
  /// Returns null if the unit has no active session.
  int? remainingSecondsFor(UnitStatus unit) {
    final booking = _activeBookingRightNowFor(unit);
    if (booking == null) return null;

    final end = _getBookingEndDateTime(booking);
    return end.difference(_now).inSeconds;
  }

  /// Returns the [SessionTimerStatus] for a unit.
  SessionTimerStatus timerStatusFor(UnitStatus unit) {
    final remaining = remainingSecondsFor(unit);
    if (remaining == null) return SessionTimerStatus.available;
    if (remaining <= 0) return SessionTimerStatus.overtime;
    if (remaining <= 600) return SessionTimerStatus.expiringSoon; // ≤10 min
    return SessionTimerStatus.active;
  }

  /// All units that currently have an active session (for timer display).
  List<UnitStatus> get activeUnitsWithTimer {
    return units.where((u) => !u.isAvailable).toList();
  }

  /// Units with ≤10 minutes remaining.
  List<UnitStatus> get expiringUnits {
    return units.where((u) => timerStatusFor(u) == SessionTimerStatus.expiringSoon).toList();
  }

  /// Units that are past their end time.
  List<UnitStatus> get overtimeUnits {
    return units.where((u) => timerStatusFor(u) == SessionTimerStatus.overtime).toList();
  }

  /// Total number of units that need attention (expiring + overtime).
  int get alertCount => expiringUnits.length + overtimeUnits.length;

  /// Extend an active booking by [additionalHours].
  void extendBooking(String bookingId, int additionalHours) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return;

    final old = _bookings[idx];
    final newDurationHours = old.durationHours + additionalHours;
    final newDuration = SessionDuration.values.firstWhere(
      (d) => d.hours == newDurationHours,
      orElse: () => SessionDuration.jam5, // cap at max
    );

    _bookings[idx] = old.copyWith(duration: newDuration);
    notifyListeners();

    if (_isApiConnected) {
      await ApiService.extendBooking(bookingId, additionalHours);
      syncWithApi();
    }
  }

  /// Update payment status for a booking.
  void updatePaymentStatus(String bookingId, PaymentStatus status) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return;

    _bookings[idx] = _bookings[idx].copyWith(paymentStatus: status);
    notifyListeners();

    if (_isApiConnected) {
      await ApiService.updatePaymentStatus(bookingId, status);
      // Optional: syncWithApi(); 
      // But we just updated local state so it's fine unless we want to be absolutely sure.
    }
  }

  /// Get the active booking for a given unit right now (public accessor).
  Booking? activeBookingFor(UnitStatus unit) => _activeBookingRightNowFor(unit);

  // ════════════════════════════════════════════════════════
  //  STATS & HELPERS
  // ════════════════════════════════════════════════════════

  List<Booking> bookingsForDate(DateTime date) {
    return _bookings.where((b) => _isSameDay(b.date, date)).toList();
  }

  int get todayRevenue {
    int total = 0;
    final todayBookings = bookingsForDate(_now);
    for (final b in todayBookings) {
      final pkg = dummyPricePackages.firstWhere(
        (p) => p.name == b.psType.bookingDisplayName,
        orElse: () => dummyPricePackages.first,
      );
      final priceTier = pkg.prices.firstWhere(
        (t) => t.duration == b.duration.displayName,
        orElse: () => pkg.prices.first,
      );
      total += priceTier.price;
    }
    return total;
  }

  /// Revenue for a specific date (used by calendar view).
  int revenueForDate(DateTime date) {
    int total = 0;
    final dateBookings = bookingsForDate(date);
    for (final b in dateBookings) {
      final pkg = dummyPricePackages.firstWhere(
        (p) => p.name == b.psType.bookingDisplayName,
        orElse: () => dummyPricePackages.first,
      );
      final priceTier = pkg.prices.firstWhere(
        (t) => t.duration == b.duration.displayName,
        orElse: () => pkg.prices.first,
      );
      total += priceTier.price;
    }
    return total;
  }

  /// All bookings in a given month (for calendar indicators).
  List<Booking> bookingsForMonth(int year, int month) {
    return _bookings
        .where((b) => b.date.year == year && b.date.month == month)
        .toList();
  }

  Map<String, int> get todayStats {
    final todayBookings = bookingsForDate(_now);
    int inUse = 0;
    final liveUnits = units;
    for (var unit in liveUnits) {
      if (!unit.isAvailable) inUse++;
    }
    return {
      'totalBookings': todayBookings.length,
      'unitsInUse': inUse,
      'unitsAvailable': liveUnits.length - inUse,
    };
  }

  void addWalkIn({
    required ConsoleType baseType,
    required String unitLabel,
    required String playerName,
    required SessionDuration duration,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    PaymentStatus paymentStatus = PaymentStatus.lunas,
    String? playedGame,
  }) {
    final startTime =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    final assignedUnit = '${baseType.displayName} $unitLabel';

    final booking = Booking(
      id:
          'WI-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}',
      customerName: playerName,
      phone: '-',
      psType: baseType,
      date: _now,
      time: startTime,
      duration: duration,
      assignedUnit: assignedUnit,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      playedGame: playedGame,
    );
    addBooking(booking);
  }

  // ════════════════════════════════════════════════════════
  //  STATUS LIVE (buat ditampilin di layar Info/Home)
  // ════════════════════════════════════════════════════════

  List<UnitStatus> get units => _templateUnits.map(_resolveStatus).toList();

  UnitStatus _resolveStatus(UnitStatus template) {
    final activeBooking = _activeBookingRightNowFor(template);
    if (activeBooking != null) {
      return template.copyWith(
        isAvailable: false,
        playerName: activeBooking.customerName,
        startTime: activeBooking.time,
        endTime: activeBooking.endTime,
        isWalkIn: activeBooking.isWalkIn,
      );
    }
    if (template.startTime != null && template.endTime != null) {
      final nowMin = _now.hour * 60 + _now.minute;
      final dStart = toMinutes(template.startTime!);
      final dEnd = toMinutes(template.endTime!);
      final withinWindow = dEnd <= dStart
          ? (nowMin >= dStart || nowMin < dEnd)
          : (nowMin >= dStart && nowMin < dEnd);
      if (withinWindow) return template;
    }
    return template.copyWith(isAvailable: true);
  }

  Booking? _activeBookingRightNowFor(UnitStatus template) {
    for (final b in _bookings) {
      if (!isBookingForUnit(b, template)) continue;
      final start = _getBookingStartDateTime(b);
      final end = _getBookingEndDateTime(b);
      if (!_now.isBefore(start) && _now.isBefore(end)) {
        return b;
      }
    }
    return null;
  }

  // ════════════════════════════════════════════════════════
  //  SCHEDULING — dipakai pas user mau BOOKING
  // ════════════════════════════════════════════════════════

  /// Cari 1 unit yang kosong buat tipe + tanggal + jam + durasi.
  UnitStatus? findAvailableUnit({
    required ConsoleType baseType,
    required DateTime date,
    required String startTime,
    required int durationHours,
  }) {
    final candidates = _templateUnits.where((u) => u.psType == baseType);
    for (final u in candidates) {
      if (_isUnitFreeForRange(u, baseType, date, startTime, durationHours)) {
        return u;
      }
    }
    return null;
  }

  /// Durasi maksimum (jam bulat) yang bisa didapat untuk tipe ini.
  int maxAvailableDurationHours({
    required ConsoleType baseType,
    required DateTime date,
    required String startTime,
    int maxHours = 5,
  }) {
    int best = 0;
    final candidates = _templateUnits.where((u) => u.psType == baseType);
    for (final u in candidates) {
      for (int h = maxHours; h >= 1; h--) {
        if (_isUnitFreeForRange(u, baseType, date, startTime, h)) {
          if (h > best) best = h;
          break;
        }
      }
    }
    return best;
  }

  /// Cari tipe PS LAIN yang unitnya kosong buat durasi penuh.
  List<ConsoleType> findAlternativeTypesForFullDuration({
    required ConsoleType excludeType,
    required DateTime date,
    required String startTime,
    required int durationHours,
  }) {
    const priority = [
      ConsoleType.ps5,
      ConsoleType.ps5Vip,
      ConsoleType.ps4,
      ConsoleType.nintendoVip,
    ];
    final result = <ConsoleType>[];
    for (final t in priority) {
      if (t == excludeType) continue;
      final unit = findAvailableUnit(
        baseType: t,
        date: date,
        startTime: startTime,
        durationHours: durationHours,
      );
      if (unit != null) result.add(t);
    }
    return result;
  }

  bool _isUnitFreeForRange(
    UnitStatus unit,
    ConsoleType baseType,
    DateTime date,
    String startTime,
    int durationHours,
  ) {
    final reqStart = toMinutes(startTime);
    final reqEnd = reqStart + durationHours * 60;

    // 1) Bentrok sama booking lain di unit yang sama & tanggal yang sama?
    for (final b in _bookings) {
      if (!_isSameDay(b.date, date)) continue;
      if (!isBookingForUnit(b, unit)) continue;
      final bStart = toMinutes(b.time);
      final bEnd = bStart + b.durationHours * 60;
      if (overlaps(reqStart, reqEnd, bStart, bEnd)) return false;
    }

    // 2) Bentrok sama jadwal dummy (simulasi walk-in hari ini)?
    if (_isSameDay(date, DateTime.now()) &&
        unit.startTime != null &&
        unit.endTime != null) {
      final dStart = toMinutes(unit.startTime!);
      final dEnd = toMinutes(unit.endTime!);
      if (overlaps(reqStart, reqEnd, dStart, dEnd)) return false;
    }

    return true;
  }

  // ════════════════════════════════════════════════════════
  //  Helpers umum
  // ════════════════════════════════════════════════════════

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ════════════════════════════════════════════════════════
  //  Booking CRUD (Hybrid: Local + API)
  // ════════════════════════════════════════════════════════

  void addBooking(Booking booking) async {
    _bookings.add(booking);
    await _saveLocalBookings();
    notifyListeners();
    if (_isApiConnected) {
      await ApiService.createBooking(booking);
      syncWithApi();
    }
  }

  void removeBooking(String id) async {
    _bookings.removeWhere((b) => b.id == id);
    await _saveLocalBookings();
    notifyListeners();
    if (_isApiConnected) {
      await ApiService.deleteBooking(id);
      syncWithApi();
    }
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
