import 'dart:math';
import '../models/booking.dart';
import '../models/enums.dart';

/// Generate dummy bookings spanning the full current month + previous month.
/// This replaces the old 14-day-only generator to support the calendar view.
List<Booking> generateMonthlyBookings(DateTime now) {
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
    'Leon',
    'Sir Toro',
    'Nisa',
    'Rina',
    'Toni',
    'Yuda',
    'Mega',
    'Rian',
    'Asep',
    'Ambatukam',
    'Rusdi',
    'Anton',
    'Ironi',
    'Imut',
    'Wawawiwin',
    'Rusli',
  ];
  const psTypes = ConsoleType.values;

  String randomTime() {
    int hour = 9 + random.nextInt(14); // 09:00 to 22:00
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  // Generate for last 45 days (covers current month + most of previous month)
  for (int i = 0; i < 45; i++) {
    DateTime targetDate = now.subtract(Duration(days: i));

    // Weekends get more bookings
    bool isWeekend =
        targetDate.weekday == DateTime.saturday ||
        targetDate.weekday == DateTime.sunday;
    int bookingsCount = isWeekend
        ? 20 +
              random.nextInt(15) // 20-34 on weekends
        : 12 + random.nextInt(13); // 12-24 on weekdays

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

      final timeStr = randomTime();
      final startHour = int.parse(timeStr.split(':').first);
      final maxHours = 24 - startHour;
      int durationHours = 1 + random.nextInt(5); // 1 to 5 hours
      if (durationHours > maxHours) {
        durationHours = maxHours;
      }
      if (durationHours < 1) durationHours = 1;
      final duration = SessionDuration.values[durationHours - 1];

      String id = isWalkIn ? 'WI-DUMMY-$i-$j' : 'ONL-DUMMY-$i-$j';

      bookings.add(
        Booking(
          id: id,
          customerName: name,
          phone: isWalkIn ? '-' : '0812${random.nextInt(9000000) + 1000000}',
          psType: type,
          date: targetDate,
          time: timeStr,
          duration: duration,
          assignedUnit: unitLabel,
        ),
      );
    }
  }

  // Sort newest first, then by time
  bookings.sort((a, b) {
    int dateCmp = b.date.compareTo(a.date);
    if (dateCmp != 0) return dateCmp;
    return b.time.compareTo(a.time);
  });

  return bookings;
}
