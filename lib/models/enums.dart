// ══════════════════════════════════════════
//  Console Type Enum
// ══════════════════════════════════════════

/// Represents the physical console/room type.
/// Replaces all hardcoded strings like 'PS4', 'PS5 VIP', etc.
enum ConsoleType {
  ps4,
  ps5,
  ps5Vip,
  nintendoVip;

  /// Display name shown in UI (e.g. 'PS5 VIP')
  String get displayName {
    switch (this) {
      case ConsoleType.ps4:
        return 'PS4';
      case ConsoleType.ps5:
        return 'PS5';
      case ConsoleType.ps5Vip:
        return 'PS5 VIP';
      case ConsoleType.nintendoVip:
        return 'Nintendo VIP';
    }
  }

  /// Name used for booking form display (e.g. 'PS4 Reguler')
  String get bookingDisplayName {
    switch (this) {
      case ConsoleType.ps4:
        return 'PS4 Reguler';
      case ConsoleType.ps5:
        return 'PS5 Reguler';
      case ConsoleType.ps5Vip:
        return 'PS5 VIP';
      case ConsoleType.nintendoVip:
        return 'Nintendo VIP';
    }
  }

  /// Internal ID used for unit IDs (e.g. 'PS4', 'PS5-VIP')
  String get unitIdPrefix {
    switch (this) {
      case ConsoleType.ps4:
        return 'PS4';
      case ConsoleType.ps5:
        return 'PS5';
      case ConsoleType.ps5Vip:
        return 'PS5-VIP';
      case ConsoleType.nintendoVip:
        return 'NIN-VIP';
    }
  }

  /// Parse from a display name string. Replaces `baseTypeOf()`.
  static ConsoleType fromDisplayName(String name) {
    switch (name) {
      case 'PS5 VIP':
        return ConsoleType.ps5Vip;
      case 'Nintendo VIP':
        return ConsoleType.nintendoVip;
      case 'PS4':
      case 'PS4 Reguler':
        return ConsoleType.ps4;
      case 'PS5':
      case 'PS5 Reguler':
        return ConsoleType.ps5;
      default:
        if (name.contains('PS4')) return ConsoleType.ps4;
        return ConsoleType.ps5;
    }
  }
}

// ══════════════════════════════════════════
//  Session Duration Enum
// ══════════════════════════════════════════

/// Represents how many hours a session lasts.
/// Replaces hardcoded strings like '1 Jam', '2 Jam', etc.
enum SessionDuration {
  jam1(1),
  jam2(2),
  jam3(3),
  jam4(4),
  jam5(5);

  final int hours;
  const SessionDuration(this.hours);

  /// Display name shown in UI (e.g. '3 Jam')
  String get displayName => '$hours Jam';

  /// Parse from display string like '3 Jam' or just '3'.
  static SessionDuration fromString(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    final h = int.tryParse(digits) ?? 1;
    return SessionDuration.values.firstWhere(
      (d) => d.hours == h,
      orElse: () => SessionDuration.jam1,
    );
  }
}
