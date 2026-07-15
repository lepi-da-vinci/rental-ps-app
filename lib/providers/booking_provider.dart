import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/enums.dart';
import '../models/ps_unit.dart';
import '../data/dummy_data.dart';
import '../data/dummy_revenue.dart';

/// Manages all booking-related state: CRUD, scheduling, live unit status.
///
/// No longer owns a Timer or admin state — those responsibilities
/// have been moved to [ClockService] and [AdminProvider] respectively.
class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];

  /// Template units — static layout of all physical units.
  final List<UnitStatus> _templateUnits = getDummyUnitStatus();

  /// Current wall-clock time, updated externally by [ClockService].
  DateTime _now = DateTime.now();

  BookingProvider() {
    // Muat data booking dummy awal
    _bookings.addAll(generateMonthlyBookings(_now));
  }

  /// Called by ProxyProvider when [ClockService] ticks.
  void updateClock(DateTime newNow) {
    if (_now.minute != newNow.minute || _now.hour != newNow.hour) {
      _now = newNow;
      notifyListeners();
    }
  }

  DateTime get now => _now;
  List<Booking> get bookings => List.unmodifiable(_bookings);
  int get bookingCount => _bookings.length;

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
      total += priceTier.price * b.durationHours;
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
      total += priceTier.price * b.durationHours;
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
      final dStart = _toMinutes(template.startTime!);
      final dEnd = _toMinutes(template.endTime!);
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
      if (b.psType != template.psType) continue;
      if (!b.assignedUnit.endsWith(template.label)) continue;
      final start = _toMinutes(b.time);
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
    final reqStart = _toMinutes(startTime);
    final reqEnd = reqStart + durationHours * 60;

    // 1) Bentrok sama booking lain di unit yang sama & tanggal yang sama?
    for (final b in _bookings) {
      if (!_isSameDay(b.date, date)) continue;
      if (b.psType != baseType) continue;
      if (!b.assignedUnit.endsWith(unit.label)) continue;
      final bStart = _toMinutes(b.time);
      final bEnd = bStart + b.durationHours * 60;
      if (_overlaps(reqStart, reqEnd, bStart, bEnd)) return false;
    }

    // 2) Bentrok sama jadwal dummy (simulasi walk-in hari ini)?
    if (_isSameDay(date, DateTime.now()) &&
        unit.startTime != null &&
        unit.endTime != null) {
      final dStart = _toMinutes(unit.startTime!);
      final dEnd = _toMinutes(unit.endTime!);
      if (_overlaps(reqStart, reqEnd, dStart, dEnd)) return false;
    }

    return true;
  }

  // ════════════════════════════════════════════════════════
  //  Helpers umum
  // ════════════════════════════════════════════════════════

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _toMinutes(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  /// true kalau rentang [s1,e1) tumpang-tindih sama [s2,e2)
  bool _overlaps(int s1, int e1, int s2, int e2) => s1 < e2 && s2 < e1;

  // ════════════════════════════════════════════════════════
  //  Booking CRUD
  // ════════════════════════════════════════════════════════

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void removeBooking(String id) {
    _bookings.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
