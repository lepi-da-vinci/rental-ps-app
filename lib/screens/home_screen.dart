import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../widgets/section_title.dart';
import '../widgets/glass_panel.dart';
import '../providers/booking_provider.dart';
import '../utils/time_helpers.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Stats derived from real data (single source of truth)
  List<Map<String, dynamic>> get _stats {
    return getHomeStats()
        .map(
          (s) => {
            'label': s.label,
            'value': s.value,
            'icon': s.icon,
            'sub': s.sub,
          },
        )
        .toList();
  }

  final List<Map<String, dynamic>> _menuCards = [
    {
      'title': 'Info',
      'desc': 'Pelajari lokasi, kontak & fasilitas.',
      'index': 1,
      'icon': Icons.info_outline,
    },
    {
      'title': 'Harga',
      'desc': 'Paket per jam, harian & weekend.',
      'index': 2,
      'icon': Icons.local_offer_outlined,
    },
    {
      'title': 'Booking',
      'desc': 'Reservasi konsol favoritmu sekarang.',
      'index': 3,
      'icon': Icons.confirmation_number_outlined,
    },
  ];

  /// Always computed from real time — never stale.
  List<Map<String, dynamic>> get _schedule {
    return getOperatingHours()
        .map((oh) => {'day': oh.day, 'hours': oh.hours, 'today': oh.isToday})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final stats = booking.todayStats;
    final totalUnits = stats['unitsInUse']! + stats['unitsAvailable']!;

    // Get today's operating hours and check if open
    final todayHours = getOperatingHours().firstWhere(
      (h) => h.isToday,
      orElse: () => getOperatingHours().first,
    );
    final open = isOpenNow(booking.now, todayHours.hours);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(
            isOpenNow: open,
            unitsInUse: stats['unitsInUse']!,
            totalUnits: totalUnits,
          ),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          const SectionTitle(
            title: 'Menu Cepat',
            subtitle: 'Semua kebutuhan main dalam satu klik',
          ),
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
          const SectionTitle(
            title: 'Jam Operasional',
            subtitle: 'Buka setiap hari',
          ),
          const SizedBox(height: 16),
          _buildOperatingHours(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroSection({
    required bool isOpenNow,
    required int unitsInUse,
    required int totalUnits,
  }) {
    final occupancy = totalUnits == 0 ? 0.0 : unitsInUse / totalUnits;
    final statusColor = isOpenNow ? AppTheme.accentCyan : AppTheme.accentRed;

    return GlassPanel(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      borderRadius: 24,
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
            child: Container(color: AppTheme.cardDark.withValues(alpha: 0.4)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.neonShadow(
                            statusColor,
                            blur: 4,
                            offset: Offset.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOpenNow ? 'LIVE · SEDANG BUKA' : 'SEDANG TUTUP',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
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
                              colors: [
                                AppTheme.accentCyan,
                                AppTheme.accentMagenta,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.neonShadow(
                              AppTheme.accentCyan,
                              blur: 10,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Booking Sekarang',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onNavigate?.call(2),
                        child: GlassPanel(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          borderRadius: 12,
                          surfaceColor: AppTheme.accentTeal.withValues(alpha: 0.15),
                          borderColor: AppTheme.accentTeal.withValues(alpha: 0.3),
                          addHighlight: false,
                          child: Center(
                            child: Text(
                              'Lihat Harga',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentTeal,
                              ),
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
                          const Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: AppTheme.accentCyan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$unitsInUse/$totalUnits',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 24,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        unitsInUse == totalUnits
                            ? 'Semua unit dalam kondisi prima'
                            : '$unitsInUse unit sedang aktif',
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
                          widthFactor: occupancy.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentCyan,
                                  AppTheme.accentMagenta,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: AppTheme.neonShadow(
                                AppTheme.accentCyan,
                                blur: 5,
                              ),
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
                            '${(occupancy * 100).round()}%',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth >= 800) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        }

        final double spacing = 12.0;
        final double itemWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _stats.map((stat) {
            return SizedBox(
              width: itemWidth,
              child: Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            stat['icon'],
                            size: 16,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 16),
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
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickAccess() {
    return Column(
      children: _menuCards.map((menu) {
        return GestureDetector(
          onTap: () => widget.onNavigate?.call(menu['index']),
          child: GlassPanel(
            enableBlur: false,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
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
                    boxShadow: AppTheme.neonShadow(
                      AppTheme.accentCyan,
                      blur: 5,
                    ),
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
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPopularGames() {
    // Ambil game populer dari gameCatalog (yang punya popularRank)
    final popularGames = gameCatalog
        .where((g) => g.popularRank != null)
        .toList();
    popularGames.sort((a, b) => a.popularRank!.compareTo(b.popularRank!));
    // Ambil maksimal 4 game
    final displayGames = popularGames.take(4).toList();

    return Column(
      children: displayGames.map((game) {
        return GlassPanel(
          enableBlur: false,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          borderRadius: 12,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Builder(
                  builder: (context) {
                    final placeholderUrl =
                        'https://placehold.co/120x120/1e1e2e/00d2ff/png?text=${Uri.encodeComponent(game.title.split(" ").take(2).join(" "))}';
                    final errorWidget = Container(
                      width: 40,
                      height: 40,
                      color: AppTheme.accentCyan.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.sports_esports,
                        size: 20,
                        color: AppTheme.accentCyan,
                      ),
                    );

                    if (game.imageUrl != null) {
                      if (game.imageUrl!.startsWith('http')) {
                        return Image.network(
                          game.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              errorWidget,
                        );
                      } else {
                        return Image.asset(
                          game.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              errorWidget,
                        );
                      }
                    } else {
                      return Image.network(
                        placeholderUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            errorWidget,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.dividerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            game.platform,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            game.genre,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
        GlassPanel(
          borderRadius: 16,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppTheme.accentCyan.withValues(alpha: 0.1)
                      : null,
                  borderRadius: BorderRadius.circular(
                    index == 0 ? 16 : (index == _schedule.length - 1 ? 16 : 0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday
                            ? AppTheme.accentRed
                            : AppTheme.textMuted.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        day['day'],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      day['hours'],
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday
                            ? AppTheme.accentRed
                            : AppTheme.textMuted,
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
            border: Border.all(
              color: AppTheme.accentCyan.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.accentCyan,
                  ),
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
