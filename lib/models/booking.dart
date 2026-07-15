import 'enums.dart';

class Booking {
  final String id;
  final String customerName;
  final String phone;
  final ConsoleType psType;
  final DateTime date;
  final String time;       // HH:mm format
  final SessionDuration duration;
  final String assignedUnit;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.psType,
    required this.date,
    required this.time,
    required this.duration,
    required this.assignedUnit,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Duration in hours (convenience getter).
  int get durationHours => duration.hours;

  /// Calculated end time string based on start time + duration.
  String get endTime {
    final parts = time.split(':');
    final endHour = (int.parse(parts[0]) + durationHours) % 24;
    return '${endHour.toString().padLeft(2, '0')}:${parts[1]}';
  }

  /// Whether this is a walk-in (non-booked) session.
  bool get isWalkIn => id.startsWith('WI-');

  Booking copyWith({
    String? id,
    String? customerName,
    String? phone,
    ConsoleType? psType,
    DateTime? date,
    String? time,
    SessionDuration? duration,
    String? assignedUnit,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      psType: psType ?? this.psType,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      assignedUnit: assignedUnit ?? this.assignedUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Booking(id: $id, name: $customerName, type: ${psType.displayName}, '
      'date: ${date.toIso8601String().substring(0, 10)}, '
      'time: $time, duration: ${duration.displayName}, unit: $assignedUnit)';
}
