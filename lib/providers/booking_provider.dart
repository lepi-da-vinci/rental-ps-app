import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/ps_unit.dart';
import '../data/dummy_data.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];
  final List<UnitStatus> _units = getDummyUnitStatus();

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<UnitStatus> get units => List.unmodifiable(_units);

  int get bookingCount => _bookings.length;

  void addBooking(Booking booking) {
    _bookings.add(booking);
    
    // Determine base type
    String baseType = booking.psType;
    if (booking.psType == 'PS5 VIP') { baseType = 'PS5 VIP'; }
    else if (booking.psType == 'Nintendo VIP') { baseType = 'Nintendo VIP'; }
    else if (booking.psType.contains('PS4')) { baseType = 'PS4'; }
    else if (booking.psType.contains('PS5')) { baseType = 'PS5'; }

    // Update the assigned unit status to in-use
    final unitIndex = _units.indexWhere((u) => u.psType == baseType && booking.assignedUnit.endsWith(u.label));
    if (unitIndex != -1) {
      final oldUnit = _units[unitIndex];
      
      // Calculate end time
      final durHours = int.tryParse(booking.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      String endTime = '-';
      try {
        final parts = booking.time.split(':');
        final endHour = (int.parse(parts[0]) + durHours) % 24;
        endTime = '${endHour.toString().padLeft(2, '0')}:${parts[1]}';
      } catch (_) {}

      _units[unitIndex] = UnitStatus(
        unitId: oldUnit.unitId,
        psType: oldUnit.psType,
        label: oldUnit.label,
        isAvailable: false,
        playerName: booking.customerName,
        startTime: booking.time,
        endTime: endTime,
        isWalkIn: false,
      );
    }
    
    notifyListeners();
  }

  void removeBooking(String id) {
    // Optionally free up the unit if a booking is deleted
    final booking = getBookingById(id);
    if (booking != null) {
      String baseType = booking.psType;
      if (booking.psType == 'PS5 VIP') { baseType = 'PS5 VIP'; }
      else if (booking.psType == 'Nintendo VIP') { baseType = 'Nintendo VIP'; }
      else if (booking.psType.contains('PS4')) { baseType = 'PS4'; }
      else if (booking.psType.contains('PS5')) { baseType = 'PS5'; }

      final unitIndex = _units.indexWhere((u) => u.psType == baseType && booking.assignedUnit.endsWith(u.label));
      if (unitIndex != -1) {
        final oldUnit = _units[unitIndex];
        _units[unitIndex] = UnitStatus(
          unitId: oldUnit.unitId,
          psType: oldUnit.psType,
          label: oldUnit.label,
          isAvailable: true,
        );
      }
    }
    
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
