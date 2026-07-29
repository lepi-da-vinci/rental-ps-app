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
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? playedGame;
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
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.lunas,
    this.playedGame,
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
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? playedGame,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      playedGame: playedGame ?? this.playedGame,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'psType': psType.name,
      'date': date.toIso8601String(),
      'time': time,
      'durationHours': duration.hours,
      'assignedUnit': assignedUnit,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'playedGame': playedGame,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final durHours = json['durationHours'] is int ? json['durationHours'] as int : 1;
    final dur = SessionDuration.values.firstWhere(
      (d) => d.hours == durHours,
      orElse: () => SessionDuration.jam1,
    );

    return Booking(
      id: json['id'] as String? ?? '',
      customerName: json['customerName'] as String? ?? 'Walk-in',
      phone: json['phone'] as String? ?? '',
      psType: ConsoleType.values.firstWhere(
        (e) => e.name == json['psType'],
        orElse: () => ConsoleType.ps4,
      ),
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      time: json['time'] as String? ?? '10:00',
      duration: dur,
      assignedUnit: json['assignedUnit'] as String? ?? '',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.lunas,
      ),
      playedGame: json['playedGame'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
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
