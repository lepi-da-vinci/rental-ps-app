import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/enums.dart';
import '../models/ps_unit.dart';
import '../data/dummy_data.dart';
import '../data/dummy_revenue.dart';
import '../utils/time_helpers.dart';
import '../services/api_service.dart';

/// Manages all booking-related state: CRUD, scheduling, live unit status, and API sync.
class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];
  final List<UnitStatus> _templateUnits = getDummyUnitStatus();
  DateTime _now = DateTime.now();

  bool _isApiConnected = false;
  bool _isSyncing = false;

  bool get isApiConnected => _isApiConnected;
  bool get isSyncing => _isSyncing;

  BookingProvider() {
    // Initial dummy data load
    _bookings.addAll(generateMonthlyBookings(_now));
    // Attempt API sync in background
    syncWithApi();
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
          _bookings.clear();
          _bookings.addAll(apiBookings);
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
    notifyListeners();

    // Fast Polling: Sync with API every 10 seconds to keep data live
    if (secondChanged && newNow.second % 10 == 0 && _isApiConnected && !_isSyncing) {
      syncWithApi();
    }
  }

  DateTime get now => _now;
  List<Booking> get bookings => List.unmodifiable(_bookings);
  int get bookingCount => _bookings.length;

  // ════════════════════════════════════════════════════════
  //  SESSION TIMER HELPERS
  // ════════════════════════════════════════════════════════

  /// Returns the remaining seconds for a unit's active session.
  /// Negative values mean the session is overtime.
  /// Returns null if the unit has no active session.
  int? remainingSecondsFor(UnitStatus unit) {
    final booking = _activeBookingRightNowFor(unit);
    if (booking == null) return null;

    final startMin = toMinutes(booking.time);
    final endMin = startMin + booking.durationHours * 60;
    final nowSec = _now.hour * 3600 + _now.minute * 60 + _now.second;
    final endSec = endMin * 60;
    return endSec - nowSec;
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
  }) {
    final startTime =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    final assignedUnit = '${baseType.displayName} $unitLabel';

    final booking = Booking(
      id: 'WI-${DateTime.now().millisecondsSinceEpoch}',
      customerName: playerName,
      phone: '-',
      psType: baseType,
      date: _now,
      time: startTime,
      duration: duration,
      assignedUnit: assignedUnit,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
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
    final nowMin = _now.hour * 60 + _now.minute;
    for (final b in _bookings) {
      if (!_isSameDay(b.date, _now)) continue;
      if (!isBookingForUnit(b, template)) continue;
      final start = toMinutes(b.time);
      final end = start + b.durationHours * 60;
      if (nowMin >= start && nowMin < end) return b;
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
    notifyListeners();
    if (_isApiConnected) {
      await ApiService.createBooking(booking);
      syncWithApi();
    }
  }

  void removeBooking(String id) async {
    _bookings.removeWhere((b) => b.id == id);
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
