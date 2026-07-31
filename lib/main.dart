import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'data/dummy_data.dart';
import 'utils/time_helpers.dart';
import 'theme/app_theme.dart';
import 'providers/clock_service.dart';
import 'providers/admin_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/home_screen.dart';
import 'screens/info_screen.dart';
import 'screens/harga_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClockService()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProxyProvider<ClockService, BookingProvider>(
          create: (_) => BookingProvider(),
          update: (_, clock, booking) => booking!..updateClock(clock.now),
        ),
      ],
      child: const TimelessApp(),
    ),
  );
}

class CustomAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class TimelessApp extends StatelessWidget {
  const TimelessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeless - PS Rental',
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomAppScrollBehavior(),
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

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _adminReady = false;
  late AnimationController _bgController;
  late Animation<Alignment> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
    _bgAnimation = Tween<Alignment>(
      begin: const Alignment(-0.6, -0.6),
      end: const Alignment(0.6, -0.2),
    ).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _navigateToAdmin() {
    _bgController.stop();
    setState(() {
      _currentIndex = 4;
      _adminReady = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentIndex != 4) return;
      setState(() => _adminReady = true);
    });
  }

  void _onNavigate(int index) {
    final adminProvider = context.read<AdminProvider>();
    if (index == 4 && !adminProvider.isAdminMode) {
      _showLoginDialog(context);
      return;
    }
    if (index == 4) {
      _navigateToAdmin();
    } else {
      setState(() => _currentIndex = index);
    }
  }

  // ─── Helpers (pakai jam dari BookingProvider, bukan Timer sendiri) ─────────

  /// Today's OperatingHour entry (null-safe)
  OperatingHour _todayHours() {
    final hours = getOperatingHours();
    return hours.firstWhere((h) => h.isToday, orElse: () => hours.first);
  }

  /// Whether the venue is currently open based on real wall-clock time
  bool _isOpenNow(DateTime now, OperatingHour today) =>
      isOpenNow(now, today.hours);

  /// Short label shown in status chip: "Sabtu · 08:00 – 23:00"
  String _statusLabel(OperatingHour today) => '${today.day} · ${today.hours}';

  @override
  Widget build(BuildContext context) {
    final now = context.watch<BookingProvider>().now;
    final todayHours = _todayHours();
    final isOpenNow = _isOpenNow(now, todayHours);
    final statusLabel = _statusLabel(todayHours);
    final isAdminMode = context.watch<AdminProvider>().isAdminMode;

    final screens = [
      HomeScreen(key: const ValueKey('home'), onNavigate: _onNavigate),
      InfoScreen(key: const ValueKey('info'), onNavigateToBooking: _onNavigate),
      HargaScreen(
        key: const ValueKey('harga'),
        onNavigateToBooking: _onNavigate,
      ),
      const BookingScreen(key: ValueKey('booking')),
      AdminScreen(
        key: const ValueKey('admin'),
        onExit: () {
          _bgController.repeat(reverse: true);
          setState(() => _currentIndex = 0);
        },
      ),
    ];

    final titles = [
      'Timeless',
      'Info Unit & Game',
      'Harga Paket',
      'Booking Online',
      'Admin Dashboard',
    ];

    if (_currentIndex == 4) {
      if (_adminReady) return screens[4];
      return _buildAdminLoading();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;

        return Scaffold(
          appBar: isLargeScreen
              ? _buildLargeAppBar(isOpenNow, statusLabel, isAdminMode, context)
              : _buildSmallAppBar(titles[_currentIndex], isAdminMode, context),
          body: AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: _bgAnimation.value,
                    radius: 1.5,
                    colors: [
                      AppTheme.accentMagenta.withValues(alpha: 0.08),
                      AppTheme.backgroundDark,
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: isLargeScreen
                ? Row(
                    children: [
                      _buildSidebar(isOpenNow, statusLabel, isAdminMode),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.98,
                                  end: 1.0,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: screens[_currentIndex],
                        ),
                      ),
                    ],
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.98,
                            end: 1.0,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: screens[_currentIndex],
                  ),
          ),
          bottomNavigationBar: isLargeScreen ? null : _buildBottomNav(),
        );
      },
    );
  }

  PreferredSizeWidget _buildSmallAppBar(
    String title,
    bool isAdminMode,
    BuildContext context,
  ) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [_buildAdminToggle(isAdminMode, context)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.dividerColor),
      ),
    );
  }

  PreferredSizeWidget _buildLargeAppBar(
    bool isOpenNow,
    String statusLabel,
    bool isAdminMode,
    BuildContext context,
  ) {
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
            'TIMELESS RENTAL PS',
            style: GoogleFonts.pressStart2p(
              fontSize: 13,
              color: AppTheme.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          _buildAdminToggle(isAdminMode, context),
          const SizedBox(width: 16),
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

  void _showLoginDialog(BuildContext context) {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool obscureText = true;
    final mainSetState = setState;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.dividerColor),
              ),
              title: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accentCyan),
                  const SizedBox(width: 10),
                  Text(
                    'Login Admin Rental PS',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameCtrl,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: GoogleFonts.spaceGrotesk(
                        color: AppTheme.textMuted,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: obscureText,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.spaceGrotesk(
                        color: AppTheme.textMuted,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textMuted,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '* Gunakan username: admin dan password: admin',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final adminProvider = context.read<AdminProvider>();
                    final success = adminProvider.login(
                      usernameCtrl.text,
                      passwordCtrl.text,
                    );
                    if (success) {
                      Navigator.pop(context);
                      mainSetState(() => _navigateToAdmin());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ Login Admin Berhasil! Selamat Datang.',
                            style: GoogleFonts.spaceGrotesk(),
                          ),
                          backgroundColor: AppTheme.accentGreen,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '❌ Username atau Password salah',
                            style: GoogleFonts.spaceGrotesk(),
                          ),
                          backgroundColor: AppTheme.accentRed,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAdminLoading() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.accentCyan),
            const SizedBox(height: 20),
            Text(
              'Loading Admin Dashboard...',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminToggle(bool isAdminMode, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onNavigate(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAdminMode
                  ? AppTheme.accentCyan.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAdminMode
                    ? AppTheme.accentCyan.withValues(alpha: 0.5)
                    : AppTheme.dividerColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdminMode ? Icons.admin_panel_settings : Icons.lock_outline,
                  size: 16,
                  color: isAdminMode ? AppTheme.accentCyan : AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  isAdminMode ? 'ADMIN' : 'LOGIN',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        isAdminMode ? AppTheme.accentCyan : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isOpenNow, String statusLabel, bool isAdminMode) {
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
              'NAVIGASI UTAMA',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1,
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

          // Bottom Operating Hour Info Card
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
