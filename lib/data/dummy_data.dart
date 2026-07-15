import 'package:flutter/material.dart';
import '../models/ps_unit.dart';
import '../models/price_package.dart';
import '../models/enums.dart';

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
    description:
        'Ruangan seru dan nyaman untuk mabar bareng teman dengan Nintendo Switch.',
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
  return [
    for (int i = 1; i <= 5; i++)
      UnitStatus(
        unitId: 'PS4-0$i',
        psType: ConsoleType.ps4,
        label: 'Unit $i',
        isAvailable: true,
      ),
    for (int i = 1; i <= 8; i++)
      UnitStatus(
        unitId: 'PS5-0$i',
        psType: ConsoleType.ps5,
        label: 'Unit $i',
        isAvailable: true,
      ),
    for (int i = 1; i <= 5; i++)
      UnitStatus(
        unitId: 'PS5-VIP-0$i',
        psType: ConsoleType.ps5Vip,
        label: 'Ruang $i',
        isAvailable: true,
      ),
    for (int i = 1; i <= 2; i++)
      UnitStatus(
        unitId: 'NIN-VIP-0$i',
        psType: ConsoleType.nintendoVip,
        label: 'Ruang $i',
        isAvailable: true,
      ),
  ];
}

// ══════════════════════════════════════════
//  Game Catalog
// ══════════════════════════════════════════
const List<GameItem> gameCatalog = [
  // ── Survival Horror & Thriller (1-10) ──
  GameItem(
    imageUrl: 'assets/gambar/resident-evil-2-remake.jpg',
    title: 'Resident Evil 2 Remake',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/resident-evil-3-remake.jpg',
    title: 'Resident Evil 3 Remake',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/resident-evil-4-remake.jpg',
    title: 'Resident Evil 4 Remake',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),

  GameItem(
    imageUrl: 'assets/gambar/resident-evil-7.jpg',
    title: 'Resident Evil 7',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/resident-evil-village.png',
    title: 'Resident Evil 8 (Village)',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/A-Plague-Tale-Innocence.jpg',
    title: 'A Plague Tale: Innocence',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/A-Plague-Tale-Requiem.jpg',
    title: 'A Plague Tale: Requiem',
    genre: 'Survival Horror & Thriller',
    platform: 'PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Little-Nightmares-II.jpg',
    title: 'Little Nightmares II',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Atomic-Heart.jpg',
    title: 'Atomic Heart',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Control.jpg',
    title: 'Control',
    genre: 'Survival Horror & Thriller',
    platform: 'PS4 PS5',
  ),

  // ── Action / Open World / Adventure (11-31) ──
  GameItem(
    imageUrl: 'assets/gambar/Red-Dead-Redemption-2.jpg',
    title: 'Red Dead Redemption 2 (RDR2)',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/grand-theft-auto-v.png',
    title: 'Grand Theft Auto V (GTA V)',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
    popularRank: 1,
  ),
  GameItem(
    imageUrl: 'assets/gambar/cyberpunk-2077.jpg',
    title: 'Cyberpunk 2077',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/spider-man-remastered.jpg',
      title: "Marvel's Spider-Man Remastered",
    genre: 'Action / Open World / Adventure',
    platform: 'PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/spider-man-miles-morales.jpg',
      title: "Marvel's Spider-Man: Miles Morales",
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/spider-man-2.jpg',
    title: 'Spider-Man 2',
    genre: 'Action / Open World / Adventure',
    platform: 'PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/death-stranding.jpg',
    title: 'Death Stranding',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Hogwarts-Legacy.jpg',
    title: 'Hogwarts Legacy',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Watch-Dogs-2.jpg',
    title: 'Watch Dogs',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Watch-Dogs-2.jpg',
    title: 'Watch Dogs 2',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Batman-Arkham-Origins.jpg',
    title: 'Batman: Arkham Origins',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Batman-Arkham-Knight.jpg',
    title: 'Batman: Arkham Knight',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Tomb-Raider.jpg',
    title: 'Tomb Raider (2013)',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Rise-of-the-Tomb-Raider.jpg',
    title: 'Rise of the Tomb Raider',
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),

  GameItem(
    imageUrl: "assets/gambar/Assassin's-Creed-IV-Black-Flag.jpg",
    title: "Assassin's Creed IV: Black Flag",
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: "assets/gambar/Assassin's-Creed-Unity.jpg",
    title: "Assassin's Creed Unity",
    genre: 'Action / Open World / Adventure',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: "assets/gambar/Assassin's-Creed-origins.jpg",
    title: "Assassin's Creed Origins",
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: "assets/gambar/Assassin's-Creed-odyssey.jpg",
    title: "Assassin's Creed Odyssey",
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: "assets/gambar/Assassin's-Creed-Mirage.jpg",
    title: "Assassin's Creed Mirage",
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: "assets/gambar/Assassin's-Creed-Valhalla.jpg",
    title: "Assassin's Creed Valhalla",
    genre: 'Action / Open World / Adventure',
    platform: 'PS4 PS5',
  ),

  // ── RPG & JRPG (32-44) ──
  GameItem(
    imageUrl: 'assets/gambar/The-Witcher-2-Assassins-of-Kings.jpg',
    title: 'The Witcher 2: Assassins of Kings',
    genre: 'RPG & JRPG',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/the-whicher-3-wild-hunt.jpg',
    title: 'The Witcher 3: Wild Hunt',
    genre: 'RPG & JRPG',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Elden-Ring.jpg',
    title: 'Elden Ring',
    genre: 'RPG & JRPG',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/final-fantasy-vii-remake.jpg',
    title: 'Final Fantasy VII Remake',
    genre: 'RPG & JRPG',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/final-fantasi-vii-rebirth.jpg',
    title: 'Final Fantasy VII Rebirth',
    genre: 'RPG & JRPG',
    platform: 'PS5',
  ),
  GameItem(imageUrl: 'assets/gambar/Final-Fantasy-XV.jpg', title: 'Final Fantasy XV', genre: 'RPG & JRPG', platform: 'PS4'),
  GameItem(imageUrl: 'assets/gambar/Final-Fantasy-XVI.png', title: 'Final Fantasy XVI', genre: 'RPG & JRPG', platform: 'PS5'),
  GameItem(
    imageUrl: 'assets/gambar/Monster-Hunter-World.jpg',
    title: 'Monster Hunter: World',
    genre: 'RPG & JRPG',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Monster-Hunter-Rise.jpg',
    title: 'Monster Hunter Rise',
    genre: 'RPG & JRPG',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/NieR-Automata.jpg',
    title: 'NieR:Automata',
    genre: 'RPG & JRPG',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: "assets/gambar/baldur's-gate-3.jpg",
    title: "Baldur's Gate 3",
    genre: 'RPG & JRPG',
    platform: 'PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Persona-3-Reload.jpg',
    title: 'Persona 3 Reload',
    genre: 'RPG & JRPG',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/The-Elder-Scrolls-V-Skyrim.png',
    title: 'The Elder Scrolls V: Skyrim',
    genre: 'RPG & JRPG',
    platform: 'PS4 PS5',
  ),

  // ── Fighting & Hack 'n Slash (45-54) ──
  GameItem(
    imageUrl: 'assets/gambar/tekken-7.jpg',
    title: 'Tekken 7',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/tekken-8.jpg',
    title: 'Tekken 8',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS5',
    popularRank: 2,
  ),
  GameItem(
    imageUrl: 'assets/gambar/Street-Fighter-6.jpg',
    title: 'Street Fighter 6',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Mortal-Kombat-1.jpeg',
    title: 'Mortal Kombat 1',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS5',
  ),
  GameItem(
    imageUrl:
        'assets/gambar/Naruto-x-Boruto-Ultimate-Ninja-Storm-Connections.jpg',
    title: 'Naruto x Boruto Ultimate Ninja Storm Connections',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Devil-May-Cry-5.jpg',
    title: 'Devil May Cry 5',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Stellar-Blade.jpg',
    title: 'Stellar Blade',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/sekiro-shadows-die-twice.jpg',
    title: 'Sekiro: Shadows Die Twice',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Hollow-Knight-silksong.jpg',
    title: 'Hollow Knight',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/god-of-war-ragnarok.jpg',
    title: 'God of War Ragnarok',
    genre: "Fighting & Hack 'n Slash",
    platform: 'PS4 PS5',
  ),

  // ── Co-op, Puzzle & Family (55-61) ──
  GameItem(
    imageUrl: 'assets/gambar/It-Takes-Two.jpg',
    title: 'It Takes Two',
    genre: 'Co-op, Puzzle & Family',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/A-Way-Out.jpg',
    title: 'A Way Out',
    genre: 'Co-op, Puzzle & Family',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Stray.jpg',
    title: 'Stray',
    genre: 'Co-op, Puzzle & Family',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Lego-Batman-3-Beyond-Gotham.jpg',
    title: 'LEGO Batman 3',
    genre: 'Co-op, Puzzle & Family',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Lego-Star-Wars-The-Skywalker-Saga.jpg',
    title: 'LEGO Star Wars: The Skywalker Saga',
    genre: 'Co-op, Puzzle & Family',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/LEGO-The -Hobbit.jpg',
    title: 'LEGO The Hobbit',
    genre: 'Co-op, Puzzle & Family',
    platform: 'PS4',
  ),
  GameItem(
    imageUrl: 'assets/gambar/LEGO-The-Lord-of the-Rings.jpg',
    title: 'LEGO The Lord of the Rings',
    genre: 'Co-op, Puzzle & Family',
    platform: 'PS4',
  ),

  // ── Racing & Sports (62-67) ──
  GameItem(
    imageUrl: 'assets/gambar/Need-for-Speed-Unbound.jpg',
    title: 'Need for Speed Unbound',
    genre: 'Racing & Sports',
    platform: 'PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/MotoGP-26.jpg',
    title: 'MotoGP 26',
    genre: 'Racing & Sports',
    platform: 'PS4 PS5',
  ),
  GameItem(
    imageUrl: 'assets/gambar/The-Crew-2.jpg',
    title: 'The Crew 2',
    genre: 'Racing & Sports',
    platform: 'PS4',
  ),

  GameItem(
    imageUrl: 'assets/gambar/ea-sports-fc-26-fifa.jpg',
    title: 'EA Sports FC 26 (FIFA)',
    genre: 'Racing & Sports',
    platform: 'PS4 PS5',
    popularRank: 3,
  ),
  GameItem(
    imageUrl: 'assets/gambar/nba-2k26.jpg',
    title: 'NBA 2K26',
    genre: 'Racing & Sports',
    platform: 'PS4 PS5',
  ),

  // ── Nintendo Exclusive & Party Games ──
  GameItem(
    imageUrl: 'assets/gambar/Mario-Kart-8-Deluxe.jpg',
    title: 'Mario Kart 8 Deluxe',
    genre: 'Co-op, Puzzle & Family',
    platform: 'Nintendo Switch',
    popularRank: 4,
  ),
  GameItem(
    imageUrl: 'assets/gambar/Super-Smash-Bros-Ultimate.jpg',
    title: 'Super Smash Bros. Ultimate',
    genre: "Fighting & Hack 'n Slash",
    platform: 'Nintendo Switch',
  ),
  GameItem(
    imageUrl: 'assets/gambar/The-Legend-of-Zelda-Breath-of-the-Wild.jpg',
    title: 'The Legend of Zelda: Breath of the Wild',
    genre: 'Action / Open World / Adventure',
    platform: 'Nintendo Switch',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Animal-Crossing-New-Horizons.jpg',
    title: 'Animal Crossing: New Horizons',
    genre: 'Co-op, Puzzle & Family',
    platform: 'Nintendo Switch',
  ),
  GameItem(
    imageUrl: 'assets/gambar/Super-Mario-Odyssey.jpg',
    title: 'Super Mario Odyssey',
    genre: 'Action / Open World / Adventure',
    platform: 'Nintendo Switch',
  ),
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
    OperatingHour(day: 'Senin', hours: '08:00 – 00:00', isToday: today == 1),
    OperatingHour(day: 'Selasa', hours: '08:00 – 00:00', isToday: today == 2),
    OperatingHour(day: 'Rabu', hours: '08:00 – 00:00', isToday: today == 3),
    OperatingHour(day: 'Kamis', hours: '08:00 – 00:00', isToday: today == 4),
    OperatingHour(day: 'Jumat', hours: '08:00 – 00:00', isToday: today == 5),
    OperatingHour(day: 'Sabtu', hours: '08:00 – 00:00', isToday: today == 6),
    OperatingHour(day: 'Minggu', hours: '08:00 – 00:00', isToday: today == 7),
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
  final closingHourStr = todayHours.hours
      .split(RegExp(r'[-–]'))
      .last
      .trim()
      .split(':')
      .first;
  int closingHour = int.tryParse(closingHourStr) ?? 22;
  if (closingHour == 0) {
    closingHour = 24;
  }

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
//  PS Type Helpers (DEPRECATED — use ConsoleType enum instead)
// ══════════════════════════════════════════

/// @deprecated Use [ConsoleType.fromDisplayName] instead.
ConsoleType baseTypeOf(String psType) => ConsoleType.fromDisplayName(psType);

/// @deprecated Use [ConsoleType.bookingDisplayName] instead.
String displayNameForBaseType(String baseType) =>
    ConsoleType.fromDisplayName(baseType).bookingDisplayName;
