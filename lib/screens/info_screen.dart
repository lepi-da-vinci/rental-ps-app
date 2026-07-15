import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../models/ps_unit.dart';
import '../widgets/section_title.dart';
import '../widgets/retro_button.dart';
import '../providers/booking_provider.dart';
import '../widgets/unit_timeline_view.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  // Game filter state
  String _gameFilter = 'semua'; // 'semua', 'populer', or a genre string
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _mainTabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFO',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tentang Timeless',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tempat main favorit sejak 2022. Kami hadir buat kamu yang cari pengalaman gaming nyaman, dengan koleksi konsol lengkap dan harga bersahabat.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isLarge = constraints.maxWidth > 600;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildInfoCard(
                              icon: Icons.location_on_outlined,
                              title: 'ALAMAT',
                              content: 'Jl. Lurus No. 56, Jambi (kiri dikit)',
                              width: isLarge
                                  ? (constraints.maxWidth - 32) / 3
                                  : constraints.maxWidth,
                            ),
                            _buildInfoCard(
                              icon: Icons.phone_outlined,
                              title: 'TELEPON',
                              content: '+62 812 3456 7890',
                              width: isLarge
                                  ? (constraints.maxWidth - 32) / 3
                                  : constraints.maxWidth,
                            ),
                            _buildInfoCard(
                              icon: Icons.email_outlined,
                              title: 'EMAIL',
                              content: 'timeless@gmail.com',
                              width: isLarge
                                  ? (constraints.maxWidth - 32) / 3
                                  : constraints.maxWidth,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Fasilitas',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isLarge = constraints.maxWidth > 600;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildFacilityCard(
                              icon: Icons.ac_unit,
                              title: 'Ruangan Ber-AC',
                              subtitle: 'Suhu terjaga 22°C sepanjang hari.',
                              width: isLarge
                                  ? (constraints.maxWidth - 48) / 4
                                  : (constraints.maxWidth - 16) / 2,
                            ),
                            _buildFacilityCard(
                              icon: Icons.wifi,
                              title: 'WiFi 200 Mbps',
                              subtitle: 'Gratis untuk semua pengunjung.',
                              width: isLarge
                                  ? (constraints.maxWidth - 48) / 4
                                  : (constraints.maxWidth - 16) / 2,
                            ),
                            _buildFacilityCard(
                              icon: Icons.coffee,
                              title: 'Cafe & Snack',
                              subtitle: 'Kopi, mie, dan cemilan siap saji.',
                              width: isLarge
                                  ? (constraints.maxWidth - 48) / 4
                                  : (constraints.maxWidth - 16) / 2,
                            ),
                            _buildFacilityCard(
                              icon: Icons.shield_outlined,
                              title: 'Konsol Original',
                              subtitle: 'Semua game & konsol resmi.',
                              width: isLarge
                                  ? (constraints.maxWidth - 48) / 4
                                  : (constraints.maxWidth - 16) / 2,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _mainTabController,
                  indicator: BoxDecoration(
                    color: AppTheme.accentCyan,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textMuted,
                  labelStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_esports_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Info Unit'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videogame_asset_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Info Game'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _mainTabController,
          children: [_buildUnitTab(), _buildGameTab()],
        ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentMagenta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentMagenta, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accentCyan, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  TAB 1: Info Unit
  // ════════════════════════════════════════════
  Widget _buildUnitTab() {
    final unitStatuses = context.watch<BookingProvider>().units;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PS type cards
          ...dummyPsUnits.map((ps) {
            final units = unitStatuses
                .where((u) => u.psType.displayName.toLowerCase() == ps.id.toLowerCase())
                .toList();
            final available = units.where((u) => u.isAvailable).length;
            final inUse = units.length - available;
            final color = ps.id == 'ps4'
                ? AppTheme.accentCyan
                : ps.id.contains('nintendo')
                ? AppTheme.accentRed
                : AppTheme.accentMagenta;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.sports_esports, color: color, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ps.name,
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 14,
                                  color: color,
                                ),
                              ),
                              Text(
                                '${ps.totalUnits} unit tersedia · ${ps.controllersPerUnit} stik/unit',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status summary
                    Row(
                      children: [
                        _buildStatusBadge(
                          '$available Tersedia',
                          AppTheme.accentGreen,
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(
                          '$inUse Digunakan',
                          AppTheme.accentRed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisExtent: 75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: units.length,
                      itemBuilder: (context, index) {
                        final unit = units[index];
                        return GestureDetector(
                          onTap: () => _showUnitDetails(unit),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: unit.isAvailable
                                  ? AppTheme.accentGreen.withValues(alpha: 0.1)
                                  : AppTheme.accentRed.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: unit.isAvailable
                                    ? AppTheme.accentGreen.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppTheme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  unit.isAvailable
                                      ? Icons.check_circle_outline
                                      : Icons.block_outlined,
                                  size: 16,
                                  color: unit.isAvailable
                                      ? AppTheme.accentGreen
                                      : AppTheme.accentRed,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  unit.label,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: unit.isAvailable
                                        ? AppTheme.accentGreen
                                        : AppTheme.accentRed,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  unit.isAvailable ? 'Kosong' : 'Dipakai',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9,
                                    color: unit.isAvailable
                                        ? AppTheme.accentGreen
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          // Cara rental
          const SizedBox(height: 8),
          const SectionTitle(title: 'Cara Rental'),
          _buildTimeline(),
          const SizedBox(height: 24),

          // S&K
          const SectionTitle(title: 'Syarat & Ketentuan'),
          _buildTerms(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  TAB 2: Info Game
  // ════════════════════════════════════════════
  Widget _buildGameTab() {
    // Filter games
    List<GameItem> filtered;
    if (_gameFilter == 'semua') {
      filtered = List.from(gameCatalog);
    } else if (_gameFilter == 'populer') {
      filtered = gameCatalog.where((g) => g.popularRank != null).toList();
      filtered.sort((a, b) => a.popularRank!.compareTo(b.popularRank!));
    } else {
      // Genre filter
      filtered = gameCatalog.where((g) => g.genre == _gameFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((g) => g.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip('Semua Game', 'semua', Icons.apps_outlined),
                const SizedBox(width: 8),
                _buildFilterChip('Paling Populer', 'populer', Icons.star_outline),
                const SizedBox(width: 8),
                _buildGenreDropdownChip(),
              ],
            ),
          ),
        ),
        
        // Search Input
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari nama game...',
              hintStyle: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
              filled: true,
              fillColor: AppTheme.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.accentCyan),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        

        const SizedBox(height: 12),

        // Game list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final game = filtered[index];
              return _buildGameCard(game);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isActive = _gameFilter == value;
    return GestureDetector(
      onTap: () => setState(() {
        _gameFilter = value;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentCyan : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppTheme.accentCyan : AppTheme.dividerColor,
          ),
          boxShadow: isActive
              ? AppTheme.neonShadow(AppTheme.accentCyan, blur: 5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.black : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreDropdownChip() {
    final genres = getUniqueGenres();
    final isGenreActive = _gameFilter != 'semua' && _gameFilter != 'populer';

    return PopupMenuButton<String>(
      onSelected: (genre) {
        setState(() => _gameFilter = genre);
      },
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      itemBuilder: (context) => genres.map((g) {
        return PopupMenuItem(
          value: g,
          child: Text(
            g,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isGenreActive ? AppTheme.accentCyan : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isGenreActive ? AppTheme.accentCyan : AppTheme.dividerColor,
          ),
          boxShadow: isGenreActive
              ? AppTheme.neonShadow(AppTheme.accentCyan, blur: 5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 16,
              color: isGenreActive ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              isGenreActive ? _gameFilter.toUpperCase() : 'Cari by Genre',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isGenreActive ? Colors.black : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(GameItem game) {
    final isPopular = game.popularRank != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Row(
          children: [
            // Game Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Builder(builder: (context) {
                final placeholderUrl = 'https://placehold.co/120x120/1e1e2e/00d2ff/png?text=${Uri.encodeComponent(game.title.split(" ").take(2).join(" "))}';
                final errorWidget = Container(
                  width: 60,
                  height: 60,
                  color: isPopular
                      ? AppTheme.accentMagenta.withValues(alpha: 0.12)
                      : AppTheme.accentCyan.withValues(alpha: 0.08),
                  child: Icon(
                    Icons.videogame_asset,
                    color: isPopular
                        ? AppTheme.accentMagenta
                        : AppTheme.accentCyan,
                    size: 24,
                  ),
                );
                
                if (game.imageUrl != null) {
                  if (game.imageUrl!.startsWith('http')) {
                    return Image.network(
                      game.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => errorWidget,
                    );
                  } else {
                    return Image.asset(
                      game.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => errorWidget,
                    );
                  }
                } else {
                  return Image.network(
                    placeholderUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => errorWidget,
                  );
                }
              }),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank badge + title
                  if (isPopular)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentMagenta.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.accentMagenta.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '#${game.popularRank} HOT',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: AppTheme.accentMagenta,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    game.title.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 12,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        game.genre,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Platform chips
                  Row(
                    children: game.platform.split(' ').map((p) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: p == 'PS5'
                              ? AppTheme.accentMagenta.withValues(alpha: 0.1)
                              : AppTheme.accentCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          p,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: p == 'PS5'
                                ? AppTheme.accentMagenta
                                : AppTheme.accentCyan,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ── Shared: Timeline ──
  Widget _buildTimeline() {
    return Column(
      children: caraKerjaRental.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == caraKerjaRental.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          step.step,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppTheme.dividerColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(step.icon, size: 18, color: AppTheme.accentCyan),
                          const SizedBox(width: 8),
                          Text(
                            step.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Shared: S&K ──
  Widget _buildTerms() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8),
          iconColor: AppTheme.textSecondary,
          collapsedIconColor: AppTheme.textMuted,
          title: Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: AppTheme.accentMagenta,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Baca Syarat & Ketentuan',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          children: syaratKetentuan.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${entry.key + 1}.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppTheme.accentMagenta,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      ),
    );
  }

  void _showUnitDetails(UnitStatus unit) {
    // Get bookings for timeline
    final provider = context.read<BookingProvider>();
    final todayBookings = provider.bookingsForDate(provider.now);
    final unitBookings = todayBookings.where((b) {
      return b.assignedUnit.endsWith(unit.label) &&
          b.assignedUnit.contains(unit.psType.displayName);
    }).toList();

    // Get today's operating hours
    final todayHours = getOperatingHours().firstWhere(
      (h) => h.isToday,
      orElse: () => getOperatingHours().first,
    );
    final parts = todayHours.hours.split(RegExp(r'[-–]'));
    int startOpHour = 10;
    int endOpHour = 22;
    if (parts.length == 2) {
      startOpHour = int.tryParse(parts[0].split(':')[0].trim()) ?? 10;
      endOpHour = int.tryParse(parts[1].split(':')[0].trim()) ?? 22;
      if (endOpHour == 0) {
        endOpHour = 24;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail ${unit.label}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: unit.isAvailable
                          ? AppTheme.accentGreen.withValues(alpha: 0.15)
                          : AppTheme.accentRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      unit.isAvailable ? 'Tersedia' : 'Sedang Dipakai',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: unit.isAvailable
                            ? AppTheme.accentGreen
                            : AppTheme.accentRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (unit.isAvailable)
                Text(
                  'Unit ini sedang kosong dan siap untuk disewa. Silakan masuk ke menu Booking untuk memesan unit ini.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                )
              else ...[
                _buildDetailRow(
                  Icons.person_outline,
                  'Pemain',
                  unit.playerName ?? 'Tidak diketahui',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.access_time,
                  'Mulai',
                  unit.startTime ?? '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.timer_off_outlined,
                  'Selesai',
                  unit.endTime ?? '-',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.info_outline,
                  'Status',
                  unit.isWalkIn ? 'Walk-in (Langsung)' : 'Booking App',
                ),
              ],
              const SizedBox(height: 24),
              const Divider(color: AppTheme.dividerColor),
              const SizedBox(height: 16),
              UnitTimelineView(
                unitBookings: unitBookings,
                startOpHour: startOpHour,
                endOpHour: endOpHour,
                dateTitle: todayHours.hours,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  label: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: AppTheme.accentCyan,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textMuted),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 28; // margin + padding
  @override
  double get maxExtent => _tabBar.preferredSize.height + 28;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.backgroundDark,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
