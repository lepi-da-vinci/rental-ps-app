import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // New layout data
  final List<Map<String, dynamic>> _stats = [
    {'label': 'Konsol Aktif', 'value': '13', 'icon': Icons.sports_esports, 'sub': 'PS4 · PS5 · Switch'},
    {'label': 'Judul Game', 'value': '67', 'icon': Icons.auto_awesome, 'sub': 'Update tiap minggu'},
    {'label': 'Pelanggan', 'value': '1.2K', 'icon': Icons.people, 'sub': 'Sejak 2022'},
    {'label': 'Rating Rata', 'value': '4.9', 'icon': Icons.star, 'sub': 'Dari 380+ review'},
  ];

  final List<Map<String, dynamic>> _menuCards = [
    {'title': 'Info', 'desc': 'Pelajari lokasi, kontak & fasilitas.', 'index': 1, 'icon': Icons.info_outline},
    {'title': 'Harga', 'desc': 'Paket per jam, harian & weekend.', 'index': 2, 'icon': Icons.local_offer_outlined},
    {'title': 'Booking', 'desc': 'Reservasi konsol favoritmu sekarang.', 'index': 3, 'icon': Icons.confirmation_number_outlined},
  ];

  final List<Map<String, dynamic>> _games = [
    {'title': 'Grand Theft Auto VI', 'platform': 'PS5', 'tag': 'Open World', 'hot': true},
    {'title': 'EA Sports FC 24', 'platform': 'PS4 · PS5', 'tag': 'Sports', 'hot': false},
    {'title': 'Tekken 8', 'platform': 'PS5', 'tag': 'Fighting', 'hot': false},
    {'title': 'Mario Kart 8 Deluxe', 'platform': 'Switch', 'tag': 'Family', 'hot': true},
    {'title': 'Resident Evil 4 Remake', 'platform': 'PS4 · PS5', 'tag': 'Horror', 'hot': false},
    {'title': 'Elden Ring', 'platform': 'PS5', 'tag': 'RPG', 'hot': false},
  ];

  final List<Map<String, dynamic>> _schedule = [
    {'day': 'Senin', 'hours': '10:00 – 22:00', 'today': false},
    {'day': 'Selasa', 'hours': '10:00 – 22:00', 'today': false},
    {'day': 'Rabu', 'hours': '10:00 – 22:00', 'today': false},
    {'day': 'Kamis', 'hours': '10:00 – 22:00', 'today': false},
    {'day': 'Jumat', 'hours': '10:00 – 23:00', 'today': false},
    {'day': 'Sabtu', 'hours': '08:00 – 23:00', 'today': true},
    {'day': 'Minggu', 'hours': '08:00 – 22:00', 'today': false},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          const SectionTitle(title: 'Menu Cepat', subtitle: 'Semua kebutuhan main dalam satu klik'),
          const SizedBox(height: 16),
          _buildQuickAccess(),
          const SizedBox(height: 32),
          SectionTitle(
            title: 'Game Populer', 
            subtitle: 'Paling banyak dimainkan minggu ini',
            action: GestureDetector(
              onTap: () => widget.onNavigate?.call(1),
              child: Text(
                'Lihat semua',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentCyan,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPopularGames(),
          const SizedBox(height: 32),
          const SectionTitle(title: 'Jam Operasional', subtitle: 'Buka setiap hari'),
          const SizedBox(height: 16),
          _buildOperatingHours(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentCyan.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentMagenta.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.cardDark.withValues(alpha: 0.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.neonShadow(AppTheme.accentCyan, blur: 4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE · SEDANG BUKA',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentCyan,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Timeless\nArcade & Rental',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 24,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sewa konsol premium, koleksi game selalu update, ruangan nyaman ber-AC. Booking cepat, harga transparan — main lebih lama, ribet lebih sedikit.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onNavigate?.call(3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accentCyan, AppTheme.accentMagenta],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.neonShadow(AppTheme.accentCyan, blur: 10),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Booking Sekarang',
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onNavigate?.call(2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Lihat Harga',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'KONSOL AKTIF',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const Icon(Icons.emoji_events, size: 16, color: AppTheme.accentCyan),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '13/13',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 24,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Semua unit dalam kondisi prima',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.dividerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.92,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.accentCyan, AppTheme.accentMagenta],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: AppTheme.neonShadow(AppTheme.accentCyan, blur: 5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Okupansi hari ini',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Text(
                            '92%',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200, // so on phone width ~350, it divides into 2 (175 each)
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 120, // fixed height prevents stretching on wide screens
      ),
      itemCount: _stats.length,
      itemBuilder: (context, index) {
        final stat = _stats[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerColor),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(stat['icon'], size: 16, color: AppTheme.accentCyan),
                  ),
                  Expanded(
                    child: Text(
                      stat['label'],
                      textAlign: TextAlign.right,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                stat['value'],
                style: GoogleFonts.pressStart2p(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stat['sub'],
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      children: _menuCards.map((menu) {
        return GestureDetector(
          onTap: () => widget.onNavigate?.call(menu['index']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.dividerColor),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentCyan, AppTheme.accentMagenta],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.neonShadow(AppTheme.accentCyan, blur: 5),
                  ),
                  child: Icon(menu['icon'], color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu['title'],
                        style: GoogleFonts.pressStart2p(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        menu['desc'],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPopularGames() {
    return Column(
      children: _games.map((game) {
        final isHot = game['hot'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sports_esports, size: 20, color: AppTheme.accentCyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game['title'],
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.dividerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            game['platform'],
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          game['tag'],
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isHot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'HOT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppTheme.accentRed,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOperatingHours() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _schedule.length,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.dividerColor.withValues(alpha: 0.5),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final day = _schedule[index];
              final isToday = day['today'] == true;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isToday ? AppTheme.accentCyan.withValues(alpha: 0.1) : null,
                  borderRadius: BorderRadius.circular(index == 0 ? 16 : (index == _schedule.length - 1 ? 16 : 0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? AppTheme.accentRed : AppTheme.textMuted.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        day['day'],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? AppTheme.textPrimary : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      day['hours'],
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? AppTheme.accentRed : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppTheme.accentCyan),
                  const SizedBox(width: 8),
                  Text(
                    'PROMO WEEKEND',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Bawa 4, Bayar 3',
                style: GoogleFonts.pressStart2p(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Berlaku Sabtu & Minggu untuk paket 3 jam ke atas.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
