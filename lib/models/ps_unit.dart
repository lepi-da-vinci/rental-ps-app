import 'enums.dart';

// ══════════════════════════════════════════
//  Session Timer Status
// ══════════════════════════════════════════

/// Visual status for the countdown timer on each unit.
enum SessionTimerStatus {
  /// Unit is available — no active session.
  available,

  /// Session is active with >10 minutes remaining.
  active,

  /// ≤10 minutes remaining — show yellow warning.
  expiringSoon,

  /// Session has passed its end time — show red alert.
  overtime,
}

class PsUnit {
  final String id;
  final String name;
  final String description;
  final String imageIcon;
  final List<String> features;
  final int totalUnits;
  final int controllersPerUnit;

  const PsUnit({
    required this.id,
    required this.name,
    required this.description,
    required this.imageIcon,
    required this.features,
    this.totalUnits = 1,
    this.controllersPerUnit = 2,
  });
}

/// Represents a single PS unit and its availability status.
class UnitStatus {
  final String unitId;       // e.g. 'PS4-01'
  final ConsoleType psType;  // enum instead of raw String
  final String label;        // e.g. 'Unit 1'
  final bool isAvailable;

  // Detail status saat sedang digunakan
  final String? playerName;  // Nama pemesan atau walk-in
  final String? startTime;   // Waktu mulai bermain
  final String? endTime;     // Waktu selesai bermain
  final bool isWalkIn;       // true jika orang datang langsung tanpa booking
  final List<String> installedGames;

  const UnitStatus({
    required this.unitId,
    required this.psType,
    required this.label,
    required this.isAvailable,
    this.playerName,
    this.startTime,
    this.endTime,
    this.isWalkIn = false,
    this.installedGames = const [],
  });

  UnitStatus copyWith({
    String? unitId,
    ConsoleType? psType,
    String? label,
    bool? isAvailable,
    String? playerName,
    String? startTime,
    String? endTime,
    bool? isWalkIn,
    List<String>? installedGames,
  }) {
    return UnitStatus(
      unitId: unitId ?? this.unitId,
      psType: psType ?? this.psType,
      label: label ?? this.label,
      isAvailable: isAvailable ?? this.isAvailable,
      playerName: playerName ?? this.playerName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isWalkIn: isWalkIn ?? this.isWalkIn,
      installedGames: installedGames ?? this.installedGames,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitStatus &&
          runtimeType == other.runtimeType &&
          unitId == other.unitId &&
          psType == other.psType &&
          label == other.label &&
          isAvailable == other.isAvailable;

  @override
  int get hashCode => Object.hash(unitId, psType, label, isAvailable);

  @override
  String toString() =>
      'UnitStatus(id: $unitId, type: ${psType.displayName}, label: $label, '
      'available: $isAvailable)';
}

/// Represents a game available for rent.
class GameItem {
  final String title;
  final String genre;
  final String platform; // e.g. 'PS4 PS5'
  final int? popularRank; // null = not in top popular
  final String? imageUrl; // optional custom image url
  final bool isAvailable;
  final String? description;
  final String? playerCount;
  final String? rating;
  final String? publisher;
  final String? releaseYear;

  const GameItem({
    required this.title,
    required this.genre,
    required this.platform,
    this.popularRank,
    this.imageUrl,
    this.isAvailable = true,
    this.description,
    this.playerCount,
    this.rating,
    this.publisher,
    this.releaseYear,
  });

  /// Helper for description with smart fallback
  String get effectiveDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!;
    }
    return 'Nikmati keseruan bermain $title di konsol $platform. Game genre $genre ini siap memberikan pengalaman gaming yang immersive dan menegangkan di Timeless Rental & Arcade.';
  }

  String get effectivePlayerCount => playerCount ?? '1-2 Pemain';
  String get effectiveRating => rating ?? 'PEGI 16+';
  String get effectivePublisher => publisher ?? 'Official Developer';
  String get effectiveReleaseYear => releaseYear ?? '2023';
}

