class Booking {
  final String id;
  final String customerName;
  final String phone;
  final String psType;
  final DateTime date;
  final String time;
  final String duration;
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
}
