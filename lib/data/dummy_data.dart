import 'package:flutter/material.dart';
import '../models/ps_unit.dart';
import '../models/price_package.dart';

// ══════════════════════════════════════════
//  PlayStation Units (PS4 & PS5 only)
// ══════════════════════════════════════════
const List<PsUnit> dummyPsUnits = [
  PsUnit(
    id: 'ps4',
    name: 'PlayStation 4',
    description:
        'Performa solid dengan grafis Full HD. Pilihan populer dengan koleksi game terbesar.',
    imageIcon: '🕹️',
    totalUnits: 5,
    controllersPerUnit: 2,
    features: [
      '2 Controller DualShock 4',
      '1TB HDD',
      '100+ game tersedia',
      'Online multiplayer ready',
      'Share Play & Remote Play',
    ],
  ),
  PsUnit(
    id: 'ps5',
    name: 'PlayStation 5',
    description:
        'Next-gen gaming dengan grafis 4K, loading super cepat, dan DualSense controller.',
    imageIcon: '🚀',
    totalUnits: 8,
    controllersPerUnit: 2,
    features: [
      '2 Controller DualSense',
      '825GB SSD ultra-cepat',
      '60+ game tersedia',
      'Grafis 4K @ 60-120fps',
      'Ray Tracing & 3D Audio',
      'Haptic Feedback & Adaptive Triggers',
    ],
  ),
  PsUnit(
    id: 'ps5 vip',
    name: 'PS5 VIP Room',
    description:
        'Ruangan private eksklusif dengan kenyamanan maksimal untuk pengalaman gaming PS5 terbaik.',
    imageIcon: '👑',
    totalUnits: 5,
    controllersPerUnit: 2,
    features: [
      'Sofa Premium & Ruang Ber-AC',
      'Smart TV OLED 65"',
      '2 Controller DualSense',
      'Gratis Minuman',
    ],
  ),
  PsUnit(
    id: 'nintendo vip',
    name: 'Nintendo VIP Room',
    description: 'Ruangan seru dan nyaman untuk mabar bareng teman dengan Nintendo Switch.',
    imageIcon: '🍄',
    totalUnits: 2,
    controllersPerUnit: 4,
    features: [
      'Sofa Santai & Beanbag',
      'Smart TV 55"',
      '4 Joy-Con / Pro Controller',
      'Cocok untuk Party Games',
    ],
  ),
];

// ══════════════════════════════════════════
//  Unit Availability Status (dummy/simulasi)
// ══════════════════════════════════════════
List<UnitStatus> getDummyUnitStatus() {
  // Simulate: some units in use, some available
  return [
    // PS4 — 5 units
    const UnitStatus(
      unitId: 'PS4-01',
      psType: 'PS4',
      label: 'Unit 1',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'PS4-02',
      psType: 'PS4',
      label: 'Unit 2',
      isAvailable: false,
      playerName: 'Budi (Walk-in)',
      startTime: '14:00',
      endTime: '16:00',
      isWalkIn: true,
    ),
    const UnitStatus(
      unitId: 'PS4-03',
      psType: 'PS4',
      label: 'Unit 3',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'PS4-04',
      psType: 'PS4',
      label: 'Unit 4',
      isAvailable: false,
      playerName: 'Sandi',
      startTime: '13:00',
      endTime: '17:00',
      isWalkIn: false,
    ),
    const UnitStatus(
      unitId: 'PS4-05',
      psType: 'PS4',
      label: 'Unit 5',
      isAvailable: true,
    ),
    // PS5 — 8 units
    const UnitStatus(
      unitId: 'PS5-01',
      psType: 'PS5',
      label: 'Unit 1',
      isAvailable: false,
      playerName: 'Riki (Walk-in)',
      startTime: '11:00',
      endTime: '13:00',
      isWalkIn: true,
    ),
    const UnitStatus(
      unitId: 'PS5-02',
      psType: 'PS5',
      label: 'Unit 2',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'PS5-03',
      psType: 'PS5',
      label: 'Unit 3',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'PS5-04',
      psType: 'PS5',
      label: 'Unit 4',
      isAvailable: false,
      playerName: 'Siska',
      startTime: '12:00',
      endTime: '16:00',
      isWalkIn: false,
    ),
    const UnitStatus(
      unitId: 'PS5-05',
      psType: 'PS5',
      label: 'Unit 5',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'PS5-06',
      psType: 'PS5',
      label: 'Unit 6',
      isAvailable: false,
      playerName: 'Adit (Walk-in)',
      startTime: '10:30',
      endTime: '12:30',
      isWalkIn: true,
    ),
    const UnitStatus(
      unitId: 'PS5-07',
      psType: 'PS5',
      label: 'Unit 7',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'PS5-08',
      psType: 'PS5',
      label: 'Unit 8',
      isAvailable: false,
      playerName: 'Dimas',
      startTime: '09:00',
      endTime: '14:00',
      isWalkIn: false,
    ),
    // PS5 VIP — 3 rooms
    const UnitStatus(
      unitId: 'PS5-VIP-01',
      psType: 'PS5 VIP',
      label: 'Ruang 1',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'PS5-VIP-02',
      psType: 'PS5 VIP',
      label: 'Ruang 2',
      isAvailable: false,
      playerName: 'Anton (Walk-in)',
      startTime: '10:00',
      endTime: '15:00',
      isWalkIn: true,
    ),
    const UnitStatus(
      unitId: 'PS5-VIP-03',
      psType: 'PS5 VIP',
      label: 'Ruang 3',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'PS5-VIP-04',
      psType: 'PS5 VIP',
      label: 'Ruang 4',
      isAvailable: false,
      playerName: 'Joko (Walk-in)',
      startTime: '08:00',
      endTime: '12:00',
      isWalkIn: true,
    ),
    const UnitStatus(
      unitId: 'PS5-VIP-05',
      psType: 'PS5 VIP',
      label: 'Ruang 5',
      isAvailable: true,
    ),
    // Nintendo VIP — 2 rooms
    const UnitStatus(
      unitId: 'NIN-VIP-01',
      psType: 'Nintendo VIP',
      label: 'Ruang 1',
      isAvailable: true,
    ),
    const UnitStatus(
      unitId: 'NIN-VIP-02',
      psType: 'Nintendo VIP',
      label: 'Ruang 2',
      isAvailable: false,
      playerName: 'Fina',
      startTime: '14:30',
      endTime: '16:30',
      isWalkIn: false,
    ),
  ];
}

// ══════════════════════════════════════════
//  Game Catalog
// ══════════════════════════════════════════
const List<GameItem> gameCatalog = [
  // ── Survival Horror & Thriller (1-10) ──
  GameItem(title: 'Resident Evil 2 Remake', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),
  GameItem(title: 'Resident Evil 3 Remake', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),
  GameItem(title: 'Resident Evil 4 Remake', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),
  GameItem(title: 'Resident Evil 7', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),
  GameItem(title: 'Resident Evil 8 (Village)', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),
  GameItem(title: 'A Plague Tale: Innocence', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),
  GameItem(title: 'A Plague Tale: Requiem', genre: 'Survival Horror & Thriller', platform: 'PS5'),
  GameItem(title: 'Little Nightmares II', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),
  GameItem(title: 'Atomic Heart', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),
  GameItem(title: 'Control', genre: 'Survival Horror & Thriller', platform: 'PS4 PS5'),

  // ── Action / Open World / Adventure (11-31) ──
  GameItem(title: 'Red Dead Redemption 2 (RDR2)', genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: 'Grand Theft Auto V (GTA V)', genre: 'Action / Open World / Adventure', platform: 'PS4 PS5', popularRank: 1, imageUrl: 'https://image.api.playstation.com/vulcan/ap/rnd/202202/2816/mYnP2bWXFTTEuoFJNkCOZdQG.png'),
  GameItem(title: 'Cyberpunk 2077', genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),
  GameItem(title: "Marvel's Spider-Man Remastered", genre: 'Action / Open World / Adventure', platform: 'PS5'),
  GameItem(title: "Marvel's Spider-Man: Miles Morales", genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),
  GameItem(title: 'Spider-Man 2', genre: 'Action / Open World / Adventure', platform: 'PS5'),
  GameItem(title: 'Death Stranding', genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),
  GameItem(title: 'Hogwarts Legacy', genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),
  GameItem(title: 'Watch Dogs', genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: 'Watch Dogs 2', genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: 'Batman: Arkham Origins', genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: 'Batman: Arkham Knight', genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: 'Tomb Raider (2013)', genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: 'Rise of the Tomb Raider', genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: 'Tomb Raider I-III Remastered', genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),
  GameItem(title: "Assassin's Creed IV: Black Flag", genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: "Assassin's Creed Unity", genre: 'Action / Open World / Adventure', platform: 'PS4'),
  GameItem(title: "Assassin's Creed Origins", genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),
  GameItem(title: "Assassin's Creed Odyssey", genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),
  GameItem(title: "Assassin's Creed Mirage", genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),
  GameItem(title: "Assassin's Creed Valhalla", genre: 'Action / Open World / Adventure', platform: 'PS4 PS5'),

  // ── RPG & JRPG (32-44) ──
  GameItem(title: 'The Witcher 2: Assassins of Kings', genre: 'RPG & JRPG', platform: 'PS4'),
  GameItem(title: 'The Witcher 3: Wild Hunt', genre: 'RPG & JRPG', platform: 'PS4 PS5'),
  GameItem(title: 'Elden Ring', genre: 'RPG & JRPG', platform: 'PS4 PS5'),
  GameItem(title: 'Final Fantasy VII Remake', genre: 'RPG & JRPG', platform: 'PS4 PS5'),
  GameItem(title: 'Final Fantasy VII Rebirth', genre: 'RPG & JRPG', platform: 'PS5'),
  GameItem(title: 'Final Fantasy XV', genre: 'RPG & JRPG', platform: 'PS4'),
  GameItem(title: 'Final Fantasy XVI', genre: 'RPG & JRPG', platform: 'PS5'),
  GameItem(title: 'Monster Hunter: World', genre: 'RPG & JRPG', platform: 'PS4'),
  GameItem(title: 'Monster Hunter Rise', genre: 'RPG & JRPG', platform: 'PS4 PS5'),
  GameItem(title: 'NieR:Automata', genre: 'RPG & JRPG', platform: 'PS4'),
  GameItem(title: "Baldur's Gate 3", genre: 'RPG & JRPG', platform: 'PS5'),
  GameItem(title: 'Persona 3 Reload', genre: 'RPG & JRPG', platform: 'PS4 PS5'),
  GameItem(title: 'The Elder Scrolls V: Skyrim', genre: 'RPG & JRPG', platform: 'PS4 PS5'),

  // ── Fighting & Hack 'n Slash (45-54) ──
  GameItem(title: 'Tekken 7', genre: "Fighting & Hack 'n Slash", platform: 'PS4'),
  GameItem(title: 'Tekken 8', genre: "Fighting & Hack 'n Slash", platform: 'PS5', popularRank: 2, imageUrl: 'https://image.api.playstation.com/vulcan/ap/rnd/202308/1715/bfd91ebcb4b2ebc4dff48aa1ec1de3fb42880c85c4004940.png'),
  GameItem(title: 'Street Fighter 6', genre: "Fighting & Hack 'n Slash", platform: 'PS4 PS5'),
  GameItem(title: 'Mortal Kombat 1', genre: "Fighting & Hack 'n Slash", platform: 'PS5'),
  GameItem(title: 'Naruto x Boruto Ultimate Ninja Storm Connections', genre: "Fighting & Hack 'n Slash", platform: 'PS4 PS5'),
  GameItem(title: 'Devil May Cry 5', genre: "Fighting & Hack 'n Slash", platform: 'PS4 PS5'),
  GameItem(title: 'Stellar Blade', genre: "Fighting & Hack 'n Slash", platform: 'PS5'),
  GameItem(title: 'Sekiro: Shadows Die Twice', genre: "Fighting & Hack 'n Slash", platform: 'PS4'),
  GameItem(title: 'Hollow Knight', genre: "Fighting & Hack 'n Slash", platform: 'PS4'),
  GameItem(title: 'God of War Ragnarok', genre: "Fighting & Hack 'n Slash", platform: 'PS4 PS5'),

  // ── Co-op, Puzzle & Family (55-61) ──
  GameItem(title: 'It Takes Two', genre: 'Co-op, Puzzle & Family', platform: 'PS4 PS5'),
  GameItem(title: 'A Way Out', genre: 'Co-op, Puzzle & Family', platform: 'PS4'),
  GameItem(title: 'Stray', genre: 'Co-op, Puzzle & Family', platform: 'PS4 PS5'),
  GameItem(title: 'LEGO Batman 3', genre: 'Co-op, Puzzle & Family', platform: 'PS4'),
  GameItem(title: 'LEGO Star Wars: The Skywalker Saga', genre: 'Co-op, Puzzle & Family', platform: 'PS4 PS5'),
  GameItem(title: 'LEGO The Hobbit', genre: 'Co-op, Puzzle & Family', platform: 'PS4'),
  GameItem(title: 'LEGO The Lord of the Rings', genre: 'Co-op, Puzzle & Family', platform: 'PS4'),

  // ── Racing & Sports (62-67) ──
  GameItem(title: 'Need for Speed Unbound', genre: 'Racing & Sports', platform: 'PS5'),
  GameItem(title: 'MotoGP 23', genre: 'Racing & Sports', platform: 'PS4 PS5'),
  GameItem(title: 'The Crew 2', genre: 'Racing & Sports', platform: 'PS4'),
  GameItem(title: 'EA Sports FC 24', genre: 'Racing & Sports', platform: 'PS4 PS5'),
  GameItem(title: 'EA Sports FC 26 (FIFA)', genre: 'Racing & Sports', platform: 'PS4 PS5', popularRank: 3, imageUrl: 'https://image.api.playstation.com/vulcan/ap/rnd/202307/1110/af866f21c2780e9df1dc6ebf77f59d4c7287fcb1745dbd4e.png'),
  GameItem(title: 'NBA 2K26', genre: 'Racing & Sports', platform: 'PS4 PS5'),

  // ── Nintendo Exclusive & Party Games ──
  GameItem(title: 'Mario Kart 8 Deluxe', genre: 'Co-op, Puzzle & Family', platform: 'Nintendo Switch', popularRank: 4),
  GameItem(title: 'Super Smash Bros. Ultimate', genre: "Fighting & Hack 'n Slash", platform: 'Nintendo Switch'),
  GameItem(title: 'The Legend of Zelda: Breath of the Wild', genre: 'Action / Open World / Adventure', platform: 'Nintendo Switch'),
  GameItem(title: 'Animal Crossing: New Horizons', genre: 'Co-op, Puzzle & Family', platform: 'Nintendo Switch'),
  GameItem(title: 'Super Mario Odyssey', genre: 'Action / Open World / Adventure', platform: 'Nintendo Switch'),
  GameItem(title: 'Splatoon 3', genre: 'Action / Open World / Adventure', platform: 'Nintendo Switch'),
];

// Extract unique genres for filter
List<String> getUniqueGenres() {
  final genres = gameCatalog.map((g) => g.genre).toSet().toList();
  genres.sort();
  return genres;
}

// ══════════════════════════════════════════
//  Price Packages (matching web version)
// ══════════════════════════════════════════
const List<PricePackage> dummyPricePackages = [
  PricePackage(
    id: 'ps4-reguler',
    name: 'PS4 Reguler',
    psType: 'PS4',
    tier: 'reguler',
    prices: [
      PriceTier(duration: '1 Jam', price: 12000),
      PriceTier(duration: '2 Jam', price: 24000),
      PriceTier(duration: '3 Jam', price: 33000),
      PriceTier(duration: '4 Jam', price: 45000),
      PriceTier(duration: '5 Jam', price: 50000),
    ],
  ),
  PricePackage(
    id: 'ps5-reguler',
    name: 'PS5 Reguler',
    psType: 'PS5',
    tier: 'reguler',
    isHighlighted: true,
    prices: [
      PriceTier(duration: '1 Jam', price: 17000),
      PriceTier(duration: '2 Jam', price: 34000),
      PriceTier(duration: '3 Jam', price: 48000),
      PriceTier(duration: '4 Jam', price: 65000),
      PriceTier(duration: '5 Jam', price: 75000),
    ],
  ),
  PricePackage(
    id: 'ps5-vip',
    name: 'PS5 VIP',
    psType: 'PS5',
    tier: 'vip',
    prices: [
      PriceTier(duration: '1 Jam', price: 25000),
      PriceTier(duration: '2 Jam', price: 50000),
      PriceTier(duration: '3 Jam', price: 70000),
      PriceTier(duration: '4 Jam', price: 95000),
      PriceTier(duration: '5 Jam', price: 110000),
    ],
  ),
  PricePackage(
    id: 'nintendo-vip',
    name: 'Nintendo VIP',
    psType: 'Nintendo',
    tier: 'vip',
    prices: [
      PriceTier(duration: '1 Jam', price: 20000),
      PriceTier(duration: '2 Jam', price: 40000),
      PriceTier(duration: '3 Jam', price: 55000),
      PriceTier(duration: '4 Jam', price: 75000),
      PriceTier(duration: '5 Jam', price: 90000),
    ],
  ),
];

// ══════════════════════════════════════════
//  Promo
// ══════════════════════════════════════════
class PromoItem {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;

  const PromoItem({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });
}

const List<PromoItem> dummyPromos = [
  PromoItem(
    title: 'Diskon 20% Member Baru',
    subtitle: 'Booking pertama kali langsung dapat potongan harga spesial!',
    emoji: '🔥',
    color: Color(0xFFC27B8E),
  ),
  PromoItem(
    title: 'Happy Hour 10:00–14:00',
    subtitle: 'Senin-Jumat dapatkan harga spesial di jam-jam siang.',
    emoji: '⏰',
    color: Color(0xFF5BA4A4),
  ),
  PromoItem(
    title: 'Paket Weekend Hemat',
    subtitle: 'Sabtu-Minggu, bawa 4 orang cuma bayar 3 orang!',
    emoji: '🎉',
    color: Color(0xFF8B7EC8),
  ),
];

// ══════════════════════════════════════════
//  Operating Hours
// ══════════════════════════════════════════
class OperatingHour {
  final String day;
  final String hours;
  final bool isToday;

  const OperatingHour({
    required this.day,
    required this.hours,
    this.isToday = false,
  });
}

List<OperatingHour> getOperatingHours() {
  final today = DateTime.now().weekday;
  return [
    OperatingHour(day: 'Senin', hours: '10:00 – 22:00', isToday: today == 1),
    OperatingHour(day: 'Selasa', hours: '10:00 – 22:00', isToday: today == 2),
    OperatingHour(day: 'Rabu', hours: '10:00 – 22:00', isToday: today == 3),
    OperatingHour(day: 'Kamis', hours: '10:00 – 22:00', isToday: today == 4),
    OperatingHour(day: 'Jumat', hours: '10:00 – 23:00', isToday: today == 5),
    OperatingHour(day: 'Sabtu', hours: '08:00 – 23:00', isToday: today == 6),
    OperatingHour(day: 'Minggu', hours: '08:00 – 22:00', isToday: today == 7),
  ];
}

// ══════════════════════════════════════════
//  Stats for Home  (single source of truth)
// ══════════════════════════════════════════
class StatItem {
  final String label;
  final String value;
  final IconData icon;
  final String sub;

  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.sub = '',
  });
}

/// Derived from actual unit and game data — never hardcoded separately.
List<StatItem> getHomeStats() {
  final totalUnits = dummyPsUnits.fold(0, (sum, u) => sum + u.totalUnits);
  return [
    StatItem(
      label: 'Konsol Aktif',
      value: '$totalUnits',
      icon: Icons.sports_esports,
      sub: 'PS4 · PS5 · Switch',
    ),
    StatItem(
      label: 'Judul Game',
      value: '${gameCatalog.length}',
      icon: Icons.auto_awesome,
      sub: 'Update tiap minggu',
    ),
    StatItem(
      label: 'Pelanggan',
      value: '1.2K',
      icon: Icons.people,
      sub: 'Sejak 2022',
    ),
    StatItem(
      label: 'Rating Rata',
      value: '4.9',
      icon: Icons.star,
      sub: 'Dari 380+ review',
    ),
  ];
}

// ══════════════════════════════════════════
//  Syarat & Ketentuan
// ══════════════════════════════════════════
const List<String> syaratKetentuan = [
  'Wajib menunjukkan KTP/kartu identitas saat booking.',
  'Pembayaran dilakukan di muka sebelum sesi dimulai.',
  'Keterlambatan pengembalian dikenakan biaya tambahan Rp 5.000/30 menit.',
  'Kerusakan alat akibat kelalaian menjadi tanggung jawab penyewa.',
  'Dilarang membawa makanan/minuman ke area bermain tanpa izin.',
  'Maksimal 4 orang per sesi per unit PS.',
  'Pembatalan booking minimal 2 jam sebelum jadwal.',
  'Manajemen berhak menolak penyewaan tanpa pemberitahuan.',
];

// ══════════════════════════════════════════
//  Cara Kerja Rental
// ══════════════════════════════════════════
class RentalStep {
  final String step;
  final String title;
  final String description;
  final IconData icon;

  const RentalStep({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<RentalStep> caraKerjaRental = [
  RentalStep(
    step: '1',
    title: 'Pilih Konsol',
    description: 'Pilih tipe PlayStation yang ingin kamu mainkan.',
    icon: Icons.sports_esports_outlined,
  ),
  RentalStep(
    step: '2',
    title: 'Booking Online',
    description: 'Isi form booking dengan data diri, tanggal, dan durasi.',
    icon: Icons.edit_calendar_outlined,
  ),
  RentalStep(
    step: '3',
    title: 'Datang & Main',
    description: 'Datang sesuai jadwal, tunjukkan konfirmasi, dan main!',
    icon: Icons.videogame_asset_outlined,
  ),
  RentalStep(
    step: '4',
    title: 'Bayar & Selesai',
    description: 'Bayar sesuai paket. Selesai, sampai jumpa lagi!',
    icon: Icons.payments_outlined,
  ),
];

// ══════════════════════════════════════════
//  Duration & Time Slot Options
// ══════════════════════════════════════════
const List<String> durationOptions = [
  '1 Jam',
  '2 Jam',
  '3 Jam',
  '4 Jam',
  '5 Jam',
];

const List<String> timeSlotOptions = [
  '08:00',
  '09:00',
  '10:00',
  '11:00',
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '16:00',
  '17:00',
  '18:00',
  '19:00',
  '20:00',
  '21:00',
];

/// Returns time slots that are valid for the given [durationHours].
/// Filters out any slot whose calculated end-time would exceed the
/// operating closing hour for the current day.
List<String> getValidTimeSlots(int durationHours) {
  // Determine today's closing hour from operating hours
  final todayHours = getOperatingHours().firstWhere(
    (h) => h.isToday,
    orElse: () => const OperatingHour(day: '', hours: '10:00 – 22:00'),
  );
  final closingHourStr = todayHours.hours.split('–').last.trim().split(':').first;
  final closingHour = int.tryParse(closingHourStr) ?? 22;

  return timeSlotOptions.where((slot) {
    final startHour = int.tryParse(slot.split(':').first) ?? 0;
    return (startHour + durationHours) <= closingHour;
  }).toList();
}

// ══════════════════════════════════════════
//  Helpers
// ══════════════════════════════════════════
String formatRupiah(int price) {
  final str = price.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
  }
  return 'Rp $buffer';
}

// ══════════════════════════════════════════
//  PS Type Helpers
// ══════════════════════════════════════════

/// Ubah pilihan user (mis. 'PS4 Reguler') jadi kategori unit fisik (mis. 'PS4')
String baseTypeOf(String psType) {
  if (psType == 'PS5 VIP') return 'PS5 VIP';
  if (psType == 'Nintendo VIP') return 'Nintendo VIP';
  if (psType.contains('PS4')) return 'PS4';
  return 'PS5';
}

/// Kebalikannya: dari kategori fisik balik ke nama paket yang tampil di form booking
String displayNameForBaseType(String baseType) {
  switch (baseType) {
    case 'PS4':
      return 'PS4 Reguler';
    case 'PS5':
      return 'PS5 Reguler';
    default:
      return baseType; // 'PS5 VIP' & 'Nintendo VIP' udah sama persis
  }
}
