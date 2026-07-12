import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/ps_unit.dart';
import '../data/dummy_data.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];

  /// Ini "jadwal dummy" — dianggap tetap (template), BUKAN status final.
  /// startTime/endTime di sini artinya "kalau sekarang jam segini, unit ini sedang dipakai".
  final List<UnitStatus> _templateUnits = getDummyUnitStatus();

  DateTime _now = DateTime.now();
  Timer? _clockTimer;

  BookingProvider() {
    // Refresh tiap 60 detik biar status unit & jam buka selalu ngikutin waktu asli.
    _clockTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  DateTime get now => _now;
  List<Booking> get bookings => List.unmodifiable(_bookings);
  int get bookingCount => _bookings.length;

  /// Status unit yang SELALU dihitung ulang sesuai jam sekarang.
  /// Gak ada lagi data yang "nyangkut" occupied padahal jamnya belum/udah lewat.
  List<UnitStatus> get units => _templateUnits.map(_resolveStatus).toList();

  UnitStatus _resolveStatus(UnitStatus template) {
    // 1) Cek dulu: ada booking ASLI dari user yang lagi jalan sekarang buat unit ini?
    final activeBooking = _findActiveBookingFor(template);
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

    // 2) Kalau gak ada booking asli, cek jadwal dummy (simulasi walk-in)
    if (template.startTime != null &&
        template.endTime != null &&
        _isWithinWindow(_now, template.startTime!, template.endTime!)) {
      return template; // occupied sesuai simulasi
    }

    // 3) Di luar jam itu semua -> unit kosong
    return UnitStatus(
      unitId: template.unitId,
      psType: template.psType,
      label: template.label,
      isAvailable: true,
    );
  }

  Booking? _findActiveBookingFor(UnitStatus template) {
    for (final b in _bookings) {
      if (!_isSameDay(b.date, _now)) continue;
      if (_baseTypeOf(b.psType) != template.psType) continue;
      if (!b.assignedUnit.endsWith(template.label)) continue;
      if (_isWithinWindow(_now, b.time, _endTimeOf(b))) return b;
    }
    return null;
  }

  String _baseTypeOf(String psType) {
    if (psType == 'PS5 VIP') return 'PS5 VIP';
    if (psType == 'Nintendo VIP') return 'Nintendo VIP';
    if (psType.contains('PS4')) return 'PS4';
    return 'PS5';
  }

  String _endTimeOf(Booking b) {
    final durHours =
        int.tryParse(b.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final parts = b.time.split(':');
    final endHour = (int.parse(parts[0]) + durHours) % 24;
    return '${endHour.toString().padLeft(2, '0')}:${parts[1]}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// true kalau `now` ada di antara start..end (handle kasus lewat tengah malam juga)
  bool _isWithinWindow(DateTime now, String start, String end) {
    int toMinutes(String t) {
      final p = t.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    final n = now.hour * 60 + now.minute;
    final s = toMinutes(start);
    final e = toMinutes(end);
    if (e <= s) return n >= s || n < e; // sesi nyebrang tengah malam
    return n >= s && n < e;
  }

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void removeBooking(String id) {
    // Gak perlu lagi manual "bebasin" unit — status dihitung ulang otomatis
    // begitu booking-nya dihapus dari list.
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
