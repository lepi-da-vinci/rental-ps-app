import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/neon_card.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _promoController = PageController();
  int _currentPromo = 0;
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPromo + 1) % dummyPromos.length;
      _promoController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroBanner(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Promo & Info'),
          _buildPromoPageView(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Menu'),
          _buildQuickAccess(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Game Populer'),
          _buildPopularGames(),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Jam Operasional'),
          _buildOperatingHours(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Hero Banner ──
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentCyan, width: 2),
        boxShadow: AppTheme.neonShadow(AppTheme.accentCyan, blur: 15),
        image: DecorationImage(
          image: const NetworkImage('https://placehold.co/600x200/1e1e2c/1e1e2c/png?text=Grid'), // Fake grid
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(AppTheme.accentCyan.withValues(alpha: 0.05), BlendMode.dstATop),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: AppTheme.neonShadow(AppTheme.accentRed, blur: 5),
                ),
                child: Text(
                  'LIVE',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.sports_esports,
                size: 32,
                color: AppTheme.accentCyan,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'TIMELESS',
            style: GoogleFonts.pressStart2p(
              fontSize: 24,
              color: AppTheme.accentCyan,
              shadows: AppTheme.neonShadow(AppTheme.accentCyan),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ARCADE & RENTAL',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentMagenta,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ──
  Widget _buildStatsRow() {
    return Row(
      children: homeStats.map((stat) {
        final isAvailableStat = stat.label.contains('Tersedia');
        final statColor = isAvailableStat ? AppTheme.accentCyan : AppTheme.textSecondary;
        return Expanded(
          flex: isAvailableStat ? 3 : 2,
          child: Container(
            margin: EdgeInsets.only(right: stat != homeStats.last ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAvailableStat ? AppTheme.accentCyan : AppTheme.dividerColor, 
                width: isAvailableStat ? 1.5 : 1
              ),
              boxShadow: isAvailableStat ? AppTheme.neonShadow(AppTheme.accentCyan, blur: 5) : null,
            ),
            child: Column(
              children: [
                Icon(stat.icon, size: isAvailableStat ? 24 : 18, color: statColor),
                const SizedBox(height: 6),
                Text(
                  stat.value,
                  style: GoogleFonts.pressStart2p(
                    fontSize: isAvailableStat ? 20 : 12,
                    color: statColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stat.label.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isAvailableStat ? AppTheme.textPrimary : AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Promo PageView with dots ──
  Widget _buildPromoPageView() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _promoController,
            itemCount: dummyPromos.length,
            onPageChanged: (i) => setState(() => _currentPromo = i),
            itemBuilder: (context, index) {
              final promo = dummyPromos[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: promo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: promo.color.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: promo.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          promo.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promo.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            promo.subtitle,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(dummyPromos.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPromo == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPromo == i
                    ? AppTheme.accentMagenta
                    : AppTheme.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Quick Access ──
  Widget _buildQuickAccess() {
    final items = [
      _QuickItem('Info', Icons.explore_outlined, AppTheme.accentTeal, 1),
      _QuickItem('Harga', Icons.star_border_outlined, AppTheme.accentMagenta, 2),
      _QuickItem('Booking', Icons.play_arrow_outlined, AppTheme.accentCyan, 3),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: item != items.last ? 10 : 0),
            child: NeonCard(
              onTap: () => widget.onNavigate?.call(item.tabIndex),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.label.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Popular Games ──
  Widget _buildPopularGames() {
    final topGames = gameCatalog.where((g) => g.popularRank != null).toList()
      ..sort((a, b) => a.popularRank!.compareTo(b.popularRank!));
    // Also add a few non-popular for variety
    final showGames = [
      ...topGames,
      ...gameCatalog.where((g) => g.popularRank == null).take(3),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: showGames.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final game = showGames[index];
          return Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    game.imageUrl ??
                        'https://placehold.co/80x80/1e1e2e/00d2ff/png?text=${Uri.encodeComponent(game.title.split(" ").take(2).join(" "))}',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 38,
                      height: 38,
                      color: AppTheme.accentMagenta.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.videogame_asset,
                        color: AppTheme.accentMagenta,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        game.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        game.platform.replaceAll(' ', ' / '),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      Text(
                        game.genre,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: AppTheme.accentTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Operating Hours ──
  Widget _buildOperatingHours() {
    final hours = getOperatingHours();
    return NeonCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: hours.map((h) {
          return Padding(
            padding: EdgeInsets.only(bottom: h != hours.last ? 8 : 0),
            child: Row(
              children: [
                if (h.isToday)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    h.day,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: h.isToday ? FontWeight.w700 : FontWeight.w400,
                      color: h.isToday
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                Text(
                  h.hours,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: h.isToday ? FontWeight.w700 : FontWeight.w400,
                    color: h.isToday
                        ? AppTheme.accentGreen
                        : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickItem {
  final String label;
  final IconData icon;
  final Color color;
  final int tabIndex;
  _QuickItem(this.label, this.icon, this.color, this.tabIndex);
}
