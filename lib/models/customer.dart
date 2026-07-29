import 'enums.dart';

class Customer {
  final String name;
  final String phone;
  final int totalBookings;
  final int totalSpent;
  final DateTime? lastVisit;
  final ConsoleType? favoriteConsole;

  const Customer({
    required this.name,
    required this.phone,
    required this.totalBookings,
    required this.totalSpent,
    this.lastVisit,
    this.favoriteConsole,
  });

  /// Get formatted phone number
  String get displayPhone => phone.isEmpty ? 'Tidak ada nomor' : phone;
}
