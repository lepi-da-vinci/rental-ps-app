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
  final String unitId; // e.g. 'PS4-01'
  final String psType; // 'PS4' or 'PS5'
  final String label; // e.g. 'Unit 1'
  final bool isAvailable;
  
  // Detail status saat sedang digunakan
  final String? playerName; // Nama pemesan atau walk-in
  final String? startTime; // Waktu mulai bermain
  final String? endTime; // Waktu selesai bermain
  final bool isWalkIn; // true jika orang datang langsung tanpa booking

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
