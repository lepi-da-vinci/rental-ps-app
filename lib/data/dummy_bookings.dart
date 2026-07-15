import 'dart:math';
import '../models/booking.dart';
import '../models/enums.dart';

List<Booking> getDummyBookings(DateTime now) {
  final random = Random(42); // fixed seed for consistent dummy data
  final bookings = <Booking>[];

  final names = [
    'Budi',
    'Sandi',
    'Riki',
    'Siska',
    'Adit',
    'Dimas',
    'Anton',
    'Joko',
    'Kayes',
    'Alep',
    'Fina',
    'Agus',
    'Lina',
    'Bayu',
    'Angga',
    'Caca',
    'Dina',
    'Wira',
    'Faris',
    'Gita',
    'Hadi',
    'Indra',
    'Jawir',
    'Leo',
    'Maya',
    'Nisa',
  ];
  const psTypes = ConsoleType.values;

  // Helper to generate a realistic time
  String randomTime() {
    int hour = 9 + random.nextInt(14); // 09:00 to 22:00
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  // Generate for the last 14 days (including today)
  for (int i = 0; i < 14; i++) {
    DateTime targetDate = now.subtract(Duration(days: i));

    // Determine how many bookings on this day (make it look busy)
    int bookingsCount = 15 + random.nextInt(15); // 15 to 29 bookings per day

    for (int j = 0; j < bookingsCount; j++) {
      bool isWalkIn = random.nextBool();
      String name = names[random.nextInt(names.length)];
      if (isWalkIn) name += ' (Walk-in)';

      ConsoleType type = psTypes[random.nextInt(psTypes.length)];
      String unitLabel;
      switch (type) {
        case ConsoleType.ps4:
          unitLabel = 'PS4 Unit ${1 + random.nextInt(5)}';
        case ConsoleType.ps5:
          unitLabel = 'PS5 Unit ${1 + random.nextInt(8)}';
        case ConsoleType.ps5Vip:
          unitLabel = 'PS5 VIP Ruang ${1 + random.nextInt(5)}';
        case ConsoleType.nintendoVip:
          unitLabel = 'Nintendo VIP Ruang ${1 + random.nextInt(2)}';
      }

      int durationHours = 1 + random.nextInt(5); // 1 to 5 hours
      final duration = SessionDuration.values[durationHours - 1];

      String id = isWalkIn ? 'WI-DUMMY-$i-$j' : 'ONL-DUMMY-$i-$j';

      bookings.add(
        Booking(
          id: id,
          customerName: name,
          phone: isWalkIn ? '-' : '0812${random.nextInt(9000000) + 1000000}',
          psType: type,
          date: targetDate,
          time: randomTime(),
          duration: duration,
          assignedUnit: unitLabel,
        ),
      );
    }
  }

  // Sort them so newest date is first, and by time
  bookings.sort((a, b) {
    int dateCmp = b.date.compareTo(a.date);
    if (dateCmp != 0) return dateCmp;
    return b.time.compareTo(a.time);
  });

  return bookings;
}
