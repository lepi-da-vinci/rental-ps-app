import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'data/dummy_data.dart';
import 'theme/app_theme.dart';
import 'providers/booking_provider.dart';
import 'screens/home_screen.dart';
import 'screens/info_screen.dart';
import 'screens/harga_screen.dart';
import 'screens/booking_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BookingProvider(),
      child: const TimelessApp(),
    ),
  );
}

class TimelessApp extends StatelessWidget {
  const TimelessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeless - PS Rental',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    setState(() => _currentIndex = index);
  }

  // ─── Helpers (pakai jam dari BookingProvider, bukan Timer sendiri) ─────────

  /// Today's OperatingHour entry (null-safe)
  OperatingHour _todayHours() {
    final hours = getOperatingHours();
    return hours.firstWhere((h) => h.isToday, orElse: () => hours.first);
  }

  /// Whether the venue is currently open based on real wall-clock time
  bool _isOpenNow(DateTime now, OperatingHour today) {
    final raw = today.hours; // e.g. "08:00 – 23:00"
    final parts = raw.split('–');
    if (parts.length < 2) return false;
    int parseHour(String s) => int.tryParse(s.trim().split(':').first) ?? 0;
    final open = parseHour(parts[0]);
    final close = parseHour(parts[1]);
    return now.hour >= open && now.hour < close;
  }

  /// Short label shown in status chip: "Sabtu · 08:00 – 23:00"
  String _statusLabel(OperatingHour today) => '${today.day} · ${today.hours}';

  @override
  Widget build(BuildContext context) {
    // Satu sumber waktu untuk seluruh app: jam dari BookingProvider.
    // Provider ini yang pegang Timer.periodic, jadi di sini tinggal "watch" aja.
    final now = context.watch<BookingProvider>().now;
    final todayHours = _todayHours();
    final isOpenNow = _isOpenNow(now, todayHours);
    final statusLabel = _statusLabel(todayHours);

    final screens = [
      HomeScreen(onNavigate: _onNavigate),
      const InfoScreen(),
      HargaScreen(onNavigateToBooking: _onNavigate),
      const BookingScreen(),
    ];

    final titles = ['Timeless', 'Info Unit & Game', 'Harga', 'Booking'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;

        return Scaffold(
          appBar: isLargeScreen
              ? _buildLargeAppBar(isOpenNow, statusLabel)
              : _buildSmallAppBar(titles[_currentIndex]),
          body: isLargeScreen
              ? Row(
                  children: [
                    _buildSidebar(isOpenNow, statusLabel),
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: screens,
                      ),
                    ),
                  ],
                )
              : IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: isLargeScreen ? null : _buildBottomNav(),
        );
      },
    );
  }

  PreferredSizeWidget _buildSmallAppBar(String title) {
    return AppBar(
      title: Text(title),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.dividerColor),
      ),
    );
  }

  PreferredSizeWidget _buildLargeAppBar(bool isOpenNow, String statusLabel) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.backgroundDark,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.splitscreen,
              size: 16,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'TIMELESS',
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              color: AppTheme.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Live status pill: open / closed
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOpenNow
                    ? AppTheme.accentGreen.withValues(alpha: 0.4)
                    : AppTheme.accentRed.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isOpenNow
                        ? AppTheme.accentGreen
                        : AppTheme.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.dividerColor),
      ),
    );
  }

  Widget _buildSidebar(bool isOpenNow, String statusLabel) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          right: BorderSide(color: AppTheme.dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentMagenta.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentMagenta.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.gamepad,
                    color: AppTheme.accentMagenta,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIMELESS',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ARCADE & RENTAL',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Navigasi',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ),

          // Menu Items
          _buildSidebarItem(0, 'Home', Icons.gamepad_outlined, Icons.gamepad),
          _buildSidebarItem(
            1,
            'Info',
            Icons.videogame_asset_outlined,
            Icons.videogame_asset,
          ),
          _buildSidebarItem(
            2,
            'Harga',
            Icons.local_play_outlined,
            Icons.local_play,
          ),
          _buildSidebarItem(
            3,
            'Booking',
            Icons.confirmation_number_outlined,
            Icons.confirmation_number,
          ),

          const Spacer(),

          // Bottom Info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOpenNow
                      ? AppTheme.accentGreen.withValues(alpha: 0.3)
                      : AppTheme.accentRed.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOpenNow
                              ? AppTheme.accentGreen
                              : AppTheme.accentRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOpenNow ? 'Buka Sekarang' : 'Sedang Tutup',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isOpenNow
                              ? AppTheme.accentGreen
                              : AppTheme.accentRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusLabel,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    int index,
    String label,
    IconData icon,
    IconData activeIcon,
  ) {
    final isActive = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => _onNavigate(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentMagenta.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppTheme.accentMagenta.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: isActive ? AppTheme.textPrimary : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.accentCyan,
        unselectedItemColor: AppTheme.textMuted,
        selectedLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad_outlined),
            activeIcon: Icon(Icons.gamepad),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_outlined),
            activeIcon: Icon(Icons.videogame_asset),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_play_outlined),
            activeIcon: Icon(Icons.local_play),
            label: 'Harga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Booking',
          ),
        ],
      ),
    );
  }
}
