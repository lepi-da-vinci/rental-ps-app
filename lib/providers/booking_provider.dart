import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/ps_unit.dart';
import '../data/dummy_data.dart';
import '../data/dummy_bookings.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];

  /// "Jadwal dummy" — dianggap tetap (template), BUKAN status final.
  /// startTime/endTime di sini artinya "kalau HARI INI jam segini, unit ini dipakai".
  final List<UnitStatus> _templateUnits = getDummyUnitStatus();

  DateTime _now = DateTime.now();
  Timer? _clockTimer;

  BookingProvider() {
    // Muat data booking dummy awal
    _bookings.addAll(getDummyBookings(_now));

    _clockTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  DateTime get now => _now;
  List<Booking> get bookings => List.unmodifiable(_bookings);
  int get bookingCount => _bookings.length;

  // ════════════════════════════════════════════════════════
  //  ADMIN MODE STATE
  // ════════════════════════════════════════════════════════
  
  bool _isAdminMode = false;
  bool get isAdminMode => _isAdminMode;

  void toggleAdminMode() {
    _isAdminMode = !_isAdminMode;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════
  //  ADMIN STATS & HELPERS
  // ════════════════════════════════════════════════════════

  List<Booking> bookingsForDate(DateTime date) {
    return _bookings.where((b) => _isSameDay(b.date, date)).toList();
  }

  int get todayRevenue {
    int total = 0;
    final todayBookings = bookingsForDate(_now);
    for (final b in todayBookings) {
      final hours = _durationHoursOf(b);
      final pkg = dummyPricePackages
          .firstWhere((p) => p.name == b.psType, orElse: () => dummyPricePackages.first);
      final priceTier = pkg.prices.firstWhere((t) => t.duration == '1 Jam', orElse: () => pkg.prices.first);
      final price = priceTier.price;
      total += price * hours;
    }
    return total;
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
    required String baseType,
    required String unitLabel,
    required String playerName,
    required int durationHours,
  }) {
    final startTime = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    final assignedUnit = '$baseType $unitLabel';
    
    // Create a booking record for the walk-in
    final booking = Booking(
      id: 'WI-${DateTime.now().millisecondsSinceEpoch}',
      customerName: playerName,
      phone: '-', // Walk-in might not have phone
      psType: displayNameForBaseType(baseType),
      date: _now,
      time: startTime,
      duration: '$durationHours Jam',
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
      return UnitStatus(
        unitId: template.unitId,
        psType: template.psType,
        label: template.label,
        isAvailable: false,
        playerName: activeBooking.customerName,
        startTime: activeBooking.time,
        endTime: _endTimeOf(activeBooking),
        isWalkIn: false,
      );
    }
    if (template.startTime != null && template.endTime != null) {
      final nowMin = _now.hour * 60 + _now.minute;
      final dStart = _toMinutes(template.startTime!);
      final dEnd = _toMinutes(template.endTime!);
      final withinWindow = dEnd <= dStart
          ? (nowMin >= dStart || nowMin < dEnd) // sesi nyebrang tengah malam
          : (nowMin >= dStart && nowMin < dEnd);
      if (withinWindow) return template;
    }
    return UnitStatus(
      unitId: template.unitId,
      psType: template.psType,
      label: template.label,
      isAvailable: true,
    );
  }

  Booking? _activeBookingRightNowFor(UnitStatus template) {
    final nowMin = _now.hour * 60 + _now.minute;
    for (final b in _bookings) {
      if (!_isSameDay(b.date, _now)) continue;
      if (baseTypeOf(b.psType) != template.psType) continue;
      if (!b.assignedUnit.endsWith(template.label)) continue;
      final start = _toMinutes(b.time);
      final end = start + _durationHoursOf(b) * 60;
      if (nowMin >= start && nowMin < end) return b;
    }
    return null;
  }

  // ════════════════════════════════════════════════════════
  //  SCHEDULING — dipakai pas user mau BOOKING (bukan status live)
  // ════════════════════════════════════════════════════════

  /// Cari 1 unit yang BENERAN kosong buat tipe + tanggal + jam + durasi tsb.
  /// Return null kalau semua unit tipe itu bentrok.
  UnitStatus? findAvailableUnit({
    required String baseType,
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

  /// Durasi maksimum (jam bulat) yang beneran bisa didapat untuk tipe ini
  /// pada jam mulai tsb — dicari unit paling longgar.
  int maxAvailableDurationHours({
    required String baseType,
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

  /// Cari tipe PS LAIN (selain yang diminta) yang unitnya kosong buat durasi PENUH.
  /// Urutan prioritas: yang paling "mirip" duluan.
  List<String> findAlternativeTypesForFullDuration({
    required String excludeType,
    required DateTime date,
    required String startTime,
    required int durationHours,
  }) {
    const priority = ['PS5', 'PS5 VIP', 'PS4', 'Nintendo VIP'];
    final result = <String>[];
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
    String baseType,
    DateTime date,
    String startTime,
    int durationHours,
  ) {
    final reqStart = _toMinutes(startTime);
    final reqEnd = reqStart + durationHours * 60;

    // 1) Bentrok sama booking ASLI lain di unit yang sama & tanggal yang sama?
    for (final b in _bookings) {
      if (!_isSameDay(b.date, date)) continue;
      if (baseTypeOf(b.psType) != baseType) continue;
      if (!b.assignedUnit.endsWith(unit.label)) continue;
      final bStart = _toMinutes(b.time);
      final bEnd = bStart + _durationHoursOf(b) * 60;
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

  int _durationHoursOf(Booking b) =>
      int.tryParse(b.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

  String _endTimeOf(Booking b) {
    final durHours = _durationHoursOf(b);
    final parts = b.time.split(':');
    final endHour = (int.parse(parts[0]) + durHours) % 24;
    return '${endHour.toString().padLeft(2, '0')}:${parts[1]}';
  }

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

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }
}
