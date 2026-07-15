import 'enums.dart';

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

  const UnitStatus({
    required this.unitId,
    required this.psType,
    required this.label,
    required this.isAvailable,
    this.playerName,
    this.startTime,
    this.endTime,
    this.isWalkIn = false,
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

  const GameItem({
    required this.title,
    required this.genre,
    required this.platform,
    this.popularRank,
    this.imageUrl,
    this.isAvailable = true,
  });
}
