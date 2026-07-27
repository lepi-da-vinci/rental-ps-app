/// Shared time-related helpers used across the app.
/// Single source of truth — never duplicate these in widget code.
library;

/// Converts "HH:mm" string to total minutes.
int toMinutes(String hhmm) {
  final p = hhmm.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

/// Returns true if the half-open ranges [s1,e1) and [s2,e2) overlap.
bool overlaps(int s1, int e1, int s2, int e2) => s1 < e2 && s2 < e1;

/// Parses "08:00 – 00:00" into (8, 24).
/// 00:00 is treated as midnight = 24 (end of the day).
(int open, int close) parseOperatingHours(String raw) {
  final parts = raw.split(RegExp(r'[-–]'));
  int parseHour(String s) {
    final h = int.tryParse(s.trim().split(':').first) ?? 0;
    return h == 0 ? 24 : h;
  }
  return (
    parseHour(parts[0]),
    parseHour(parts.length > 1 ? parts[1] : parts[0]),
  );
}

/// Whether the venue is open right now based on raw hours string.
bool isOpenNow(DateTime now, String rawHours) {
  final (open, close) = parseOperatingHours(rawHours);
  return now.hour >= open && now.hour < close;
}

/// Extracts the unit index number from a string (e.g. "PS4 Unit 1" -> 1, "PS5 VIP Ruang 3" -> 3).
int? extractUnitNumber(String text) {
  final matches = RegExp(r'\d+').allMatches(text);
  if (matches.isEmpty) return null;
  return int.tryParse(matches.last.group(0)!);
}

/// Returns true if a booking belongs to a specific unit, matching both console type and unit number.
bool isBookingForUnit(dynamic booking, dynamic unit) {
  if (booking.psType != unit.psType) return false;

  final bNum = extractUnitNumber(booking.assignedUnit as String);
  final uNum = extractUnitNumber(unit.label as String) ?? extractUnitNumber(unit.unitId as String);

  if (bNum != null && uNum != null) {
    return bNum == uNum;
  }

  return (booking.assignedUnit as String).endsWith(unit.label as String);
}

