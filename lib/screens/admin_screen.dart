import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../providers/clock_service.dart';
import '../data/dummy_data.dart';
import '../models/ps_unit.dart';
import '../models/enums.dart';
import '../widgets/glass_panel.dart';
import '../widgets/clay_stat_card.dart';
import '../widgets/section_title.dart';
import '../widgets/unit_timeline_view.dart';
import '../widgets/session_timer_card.dart';
import '../widgets/alert_banner.dart';
import '../utils/time_helpers.dart';
import '../widgets/receipt_dialog.dart';
import '../widgets/customer_list_tab.dart';
import '../utils/download_helper.dart';

enum SessionInputMode { walkIn, booking }

class AdminScreen extends StatefulWidget {
  final VoidCallback? onExit;
  const AdminScreen({super.key, this.onExit});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _activeTabIndex = 0;

  // Calendar state for Data Booking
  late DateTime _bookingCalendarMonth;
  DateTime? _selectedBookingDate;

  // Calendar state for Data Pendapatan
  late DateTime _revenueCalendarMonth;
  DateTime? _selectedRevenueDate;

  final List<String> tabLabels = [
    'Dashboard',
    'Rental',
    'Data Booking',
    'Data Pendapatan',
    'Jadwal Hari Ini',
    'Pelanggan',
  ];

  final List<IconData> tabIcons = [
    Icons.dashboard_rounded,
    Icons.videogame_asset_rounded,
    Icons.calendar_month_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.view_agenda_rounded,
    Icons.people_alt_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _bookingCalendarMonth = DateTime(now.year, now.month);
    _revenueCalendarMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      floatingActionButton: isSmall
          ? FloatingActionButton.extended(
              onPressed: () => _showAddSessionDialog(
                context,
                initialMode: SessionInputMode.booking,
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: Text(
                'Tambah Sesi',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              backgroundColor: AppTheme.accentMagenta,
            )
          : null,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.accentCyan),
          onPressed: () {
            widget.onExit?.call();
            Navigator.maybePop(context);
          },
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      backgroundColor: AppTheme.backgroundDark,
      body: Builder(
        builder: (context) {
          try {
            return SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab Bar & Action Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceDark,
                      border: Border(
                        bottom: BorderSide(color: AppTheme.dividerColor, width: 1),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final isSmall = MediaQuery.of(context).size.width < 600;
                        
                        final tabsWidget = SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(tabLabels.length, (index) {
                              final isActive = _activeTabIndex == index;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _activeTabIndex = index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppTheme.accentCyan.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isActive
                                            ? AppTheme.accentCyan
                                            : AppTheme.dividerColor.withValues(alpha: 0.5),
                                        width: isActive ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          tabIcons[index],
                                          size: 16,
                                          color: isActive
                                              ? AppTheme.accentCyan
                                              : AppTheme.textMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          tabLabels[index],
                                          style: GoogleFonts.spaceGrotesk(
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontSize: 13,
                                            color: isActive
                                                ? AppTheme.accentCyan
                                                : AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );

                        final actionButton = ElevatedButton.icon(
                          onPressed: () => _showAddSessionDialog(
                            context,
                            initialMode: SessionInputMode.booking,
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(
                            '+ Tambah Sesi / Booking',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentMagenta,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );

                        if (isSmall) {
                          return tabsWidget;
                        } else {
                          return Row(
                            children: [
                              Expanded(child: tabsWidget),
                              const SizedBox(width: 12),
                              actionButton,
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  // Tab Content Views
                  Expanded(
                    child: _buildTabContent(_activeTabIndex),
                  ),
                ],
              ),
            );
          } catch (e, stack) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: $e', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    Text('$stack', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildUnitTimeline();
      case 2:
        return _buildBookingCalendar();
      case 3:
        return _buildRevenueCalendar();
      case 4:
        return _buildTodayBookings();
      case 5:
        return const CustomerListTab();
      default:
        return _buildDashboard();
    }
  }

  // ════════════════════════════════════════════════════════
  //  TAB 1: DASHBOARD
  // ════════════════════════════════════════════════════════

  Widget _buildDashboard() {
    final isSmall = MediaQuery.of(context).size.width < 600;
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final stats = provider.todayStats;
        final revenue = provider.todayRevenue;

        return Builder(
          builder: (context) {
            try {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildApiServerCard(context, provider),
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Ringkasan Hari Ini',
                subtitle: 'Statistik rental untuk hari ini',
              ),
              const SizedBox(height: 16),
              if (provider.alertCount > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'PERHATIAN: Ada ${provider.alertCount} unit yang sesinya hampir habis (≤10 menit) atau sudah melebihi waktu (Overtime)!',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 20),
              if (isSmall)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Booking', '${stats['totalBookings']}', Icons.book_online, AppTheme.accentMagenta)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Unit Dipakai', '${stats['unitsInUse']}', Icons.videogame_asset, AppTheme.accentCyan)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Unit Kosong', '${stats['unitsAvailable']}', Icons.event_available, AppTheme.accentGreen)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Pemasukan Hari Ini', formatRupiah(revenue), Icons.payments_outlined, AppTheme.accentTeal)),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Booking', '${stats['totalBookings']}', Icons.book_online, AppTheme.accentMagenta)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Unit Dipakai', '${stats['unitsInUse']}', Icons.videogame_asset, AppTheme.accentCyan)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Unit Kosong', '${stats['unitsAvailable']}', Icons.event_available, AppTheme.accentGreen)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Pemasukan Hari Ini', formatRupiah(revenue), Icons.payments_outlined, AppTheme.accentTeal)),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // ── Session Timer Cards ──
              _buildSessionTimersSection(provider),
                ],
              ),
            );
            } catch (e, stack) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Dashboard Error: $e\n$stack', style: const TextStyle(color: Colors.red)),
                ),
              );
            }
          }
        );
      },
    );
  }

  Widget _buildApiServerCard(BuildContext context, BookingProvider provider) {
    final isOnline = provider.isApiConnected;
    final isSyncing = provider.isSyncing;
    final statusColor = isOnline ? AppTheme.accentGreen : AppTheme.accentCyan;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOnline
                  ? 'SYSTEM CLOUD BACKEND CONNECTED'
                  : 'MODE LOKAL / OFFLINE SIMULATED',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (isSyncing)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accentCyan,
              ),
            )
          else
            IconButton(
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: AppTheme.accentCyan,
              ),
              tooltip: 'Sinkronkan Ulang',
              onPressed: () => provider.syncWithApi(),
            ),
        ],
      ),
    );
  }



  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      height: 136,
      child: ClayStatCard(
        label: title,
        value: value,
        icon: icon,
        color: color,
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  SESSION TIMERS SECTION (Dashboard)
  // ════════════════════════════════════════════════════════

  Widget _buildSessionTimersSection(BookingProvider provider) {
    final activeUnits = provider.activeUnitsWithTimer;

    if (activeUnits.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Sesi Aktif',
            subtitle: 'Tidak ada unit yang sedang digunakan',
          ),
          const SizedBox(height: 12),
          GlassPanel(
            enableBlur: false,
            padding: const EdgeInsets.all(24),
            borderRadius: 16,
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.videogame_asset_off,
                    color: AppTheme.textMuted.withValues(alpha: 0.4),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Semua unit tersedia',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Consumer<ClockService>(
      builder: (context, clockService, _) {
        // Sort: overtime first, then expiring, then active
        activeUnits.sort((a, b) {
          final statusA = provider.timerStatusFor(a).index;
          final statusB = provider.timerStatusFor(b).index;
          // Overtime (3) > ExpiringSoon (2) > Active (1)
          return statusB.compareTo(statusA);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert banner
            SessionAlertBanner(
              expiringCount: provider.expiringUnits.length,
              overtimeCount: provider.overtimeUnits.length,
            ),

            SectionTitle(
              title: 'Sesi Aktif',
              subtitle: '${activeUnits.length} unit sedang digunakan',
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentCyan.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 12, color: AppTheme.accentCyan),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentCyan,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        ...activeUnits.map((unit) {
          final booking = provider.activeBookingFor(unit);
          final remaining = provider.remainingSecondsFor(unit);
          final status = provider.timerStatusFor(unit);

          return SessionTimerCard(
            unit: unit,
            activeBooking: booking,
            remainingSeconds: remaining,
            timerStatus: status,
            onExtend: booking != null
                ? () => _handleExtendSession(context, provider, booking, unit)
                : null,
            onFinish: booking != null
                ? () => _handleFinishSession(context, provider, booking)
                : null,
            onChangeGame: booking != null
                ? () => _showChangeGameDialog(context, provider, booking, unit)
                : null,
          );
        }),
      ],
    );
  },
);
  }

  void _showChangeGameDialog(
    BuildContext context,
    BookingProvider provider,
    Booking booking,
    UnitStatus unit,
  ) {
    final installed = unit.installedGames;
    final customGameController = TextEditingController(text: booking.playedGame ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.dividerColor),
          ),
          title: Row(
            children: [
              const Icon(Icons.videogame_asset, color: AppTheme.accentCyan),
              const SizedBox(width: 10),
              Text(
                'Ganti Game Sesi',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemain: ${booking.customerName} (${unit.label})',
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pilih dari game terinstall:',
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: installed.map((game) {
                    final isSelected = customGameController.text == game;
                    return InkWell(
                      onTap: () {
                        customGameController.text = game;
                        (ctx as Element).markNeedsBuild();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.accentCyan.withValues(alpha: 0.2) : AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppTheme.accentCyan : AppTheme.dividerColor,
                          ),
                        ),
                        child: Text(
                          game,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isSelected ? AppTheme.accentCyan : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Atau ketik nama game secara manual:',
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: customGameController,
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Nama Game (mis. Tekken 8)',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final selectedGame = customGameController.text.trim();
                if (selectedGame.isNotEmpty) {
                  provider.updateBookingGame(booking.id, selectedGame);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ Game diubah ke: ${selectedGame.isEmpty ? "Belum diset" : selectedGame}',
                      style: GoogleFonts.spaceGrotesk(),
                    ),
                    backgroundColor: AppTheme.accentGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.black,
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleExtendSession(
    BuildContext context,
    BookingProvider provider,
    Booking booking,
    UnitStatus unit,
  ) {
    // Check if extending would exceed max duration (5 hours)
    if (booking.durationHours >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Durasi sudah maksimal (5 jam)',
            style: GoogleFonts.spaceGrotesk(),
          ),
          backgroundColor: AppTheme.warningYellow,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Row(
          children: [
            const Icon(Icons.add_alarm, color: AppTheme.accentCyan),
            const SizedBox(width: 10),
            Text(
              'Perpanjang Sesi',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Perpanjang sesi ${booking.customerName} di ${unit.psType.displayName} ${unit.label} sebanyak +1 jam?\n\n'
          'Durasi baru: ${booking.durationHours + 1} Jam\n'
          'Selesai: ${_calculateNewEndTime(booking, 1)}',
          style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 50), () {
                if (mounted) provider.extendBooking(booking.id, 1);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ Sesi ${booking.customerName} diperpanjang +1 jam',
                    style: GoogleFonts.spaceGrotesk(),
                  ),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Perpanjang',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateNewEndTime(Booking booking, int additionalHours) {
    final parts = booking.time.split(':');
    final endHour = (int.parse(parts[0]) + booking.durationHours + additionalHours) % 24;
    return '${endHour.toString().padLeft(2, '0')}:${parts[1]}';
  }

  void _handleFinishSession(
    BuildContext context,
    BookingProvider provider,
    Booking booking,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        title: Row(
          children: [
            const Icon(Icons.stop_circle_outlined, color: AppTheme.accentRed),
            const SizedBox(width: 10),
            Text(
              'Selesaikan Sesi',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Selesaikan sesi ${booking.customerName}?\nBooking ini akan dihapus dari daftar aktif.',
          style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 50), () {
                if (mounted) provider.removeBooking(booking.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ Sesi ${booking.customerName} selesai',
                    style: GoogleFonts.spaceGrotesk(),
                  ),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Selesaikan',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAB 2: TIMELINE UNIT
  // ════════════════════════════════════════════════════════

  Widget _buildUnitTimeline() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final liveUnits = provider.units;
        // Group by baseType
        final grouped = <ConsoleType, List<UnitStatus>>{};
        for (var u in liveUnits) {
          grouped.putIfAbsent(u.psType, () => []).add(u);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            final type = grouped.keys.elementAt(index);
            final units = grouped[type]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0) const SizedBox(height: 24),
                Text(
                  type.displayName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentCyan,
                  ),
                ),
                const SizedBox(height: 12),
                ...units.map((u) => _buildTimelineRow(context, u)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineRow(BuildContext context, UnitStatus unit) {
    final provider = context.read<BookingProvider>();
    final todayBookings = provider.bookingsForDate(provider.now);

    // Filter bookings specific to this unit.
    final unitBookings = todayBookings.where((b) {
      return isBookingForUnit(b, unit);
    }).toList();

    // Get today's operating hours
    final todayHours = getOperatingHours().firstWhere(
      (h) => h.isToday,
      orElse: () => getOperatingHours().first,
    );
    final (startOpHour, endOpHour) = parseOperatingHours(todayHours.hours);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(),
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            title: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unit.label.replaceAll('Unit ', '#'),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: unit.isAvailable
                      ? Text(
                          'Tersedia',
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unit.playerName ?? 'Unknown',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  unit.isWalkIn
                                      ? Icons.directions_walk
                                      : Icons.book_online,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${unit.startTime} - ${unit.endTime}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
            children: [
              const Divider(color: AppTheme.dividerColor),
              const SizedBox(height: 12),
              UnitTimelineView(
                unitBookings: unitBookings,
                startOpHour: startOpHour,
                endOpHour: endOpHour,
                dateTitle: todayHours.hours,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAB 3: DATA BOOKING (Calendar)
  // ════════════════════════════════════════════════════════

  static const _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _dayHeaders = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  Widget _buildBookingCalendar() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final year = _bookingCalendarMonth.year;
        final month = _bookingCalendarMonth.month;
        final monthBookings = provider.bookingsForMonth(year, month);

        // Group bookings by day
        final bookingsByDay = <int, List<Booking>>{};
        for (var b in monthBookings) {
          bookingsByDay.putIfAbsent(b.date.day, () => []).add(b);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildCalendarHeader(
                year: year,
                month: month,
                onPrev: () => setState(() {
                  _bookingCalendarMonth = DateTime(year, month - 1);
                  _selectedBookingDate = null;
                }),
                onNext: () => setState(() {
                  _bookingCalendarMonth = DateTime(year, month + 1);
                  _selectedBookingDate = null;
                }),
              ),
              const SizedBox(height: 16),
              _buildCalendarGrid(
                year: year,
                month: month,
                selectedDate: _selectedBookingDate,
                onDateTap: (date) {
                  setState(() {
                    if (_selectedBookingDate != null &&
                        _selectedBookingDate!.day == date.day &&
                        _selectedBookingDate!.month == date.month) {
                      _selectedBookingDate = null;
                    } else {
                      _selectedBookingDate = date;
                    }
                  });
                },
                cellBuilder: (day) {
                  final count = bookingsByDay[day]?.length ?? 0;
                  return count > 0
                      ? Text(
                          '$count',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentCyan,
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
              if (_selectedBookingDate != null) ...[
                const SizedBox(height: 20),
                _buildBookingDetailForDate(provider, _selectedBookingDate!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingDetailForDate(BookingProvider provider, DateTime date) {
    final bookings = provider.bookingsForDate(date);
    bookings.sort((a, b) => a.time.compareTo(b.time));

    final dayStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentCyan.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppTheme.accentCyan,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Booking $dayStr',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentCyan,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${bookings.length} booking',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentCyan,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (bookings.isEmpty)
          GlassPanel(
            enableBlur: false,
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            child: Center(
              child: Text(
                'Tidak ada booking di tanggal ini',
                style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
              ),
            ),
          )
        else
          ...bookings.map((b) {
            final isWalkIn = b.id.startsWith('WI-');
            final bookingColor = AppTheme.getBookingColor(b.id);
            return GlassPanel(
              enableBlur: false,
              margin: const EdgeInsets.only(bottom: 8),
              borderRadius: 10,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: bookingColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              isWalkIn ? Icons.directions_walk : Icons.language,
                              color: isWalkIn
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentCyan,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.customerName,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${b.assignedUnit} • ${b.time} (${b.duration.displayName})',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.receipt_long,
                                color: AppTheme.accentCyan,
                                size: 18,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => ReceiptDialog(booking: b),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppTheme.accentRed,
                                size: 18,
                              ),
                              onPressed: () async {
                                final confirm = await _confirmDeleteDialog(
                                  context,
                                );
                                if (confirm == true) {
                                  provider.removeBooking(b.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Booking ${b.customerName} dihapus',
                                        ),
                                        backgroundColor: AppTheme.accentRed,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAB 4: DATA PENDAPATAN (Calendar)
  // ════════════════════════════════════════════════════════

  Widget _buildRevenueCalendar() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final year = _revenueCalendarMonth.year;
        final month = _revenueCalendarMonth.month;
        final daysInMonth = DateTime(year, month + 1, 0).day;

        // Calculate total month revenue
        int totalMonthRevenue = 0;
        final revenueByDay = <int, int>{};
        for (int d = 1; d <= daysInMonth; d++) {
          final date = DateTime(year, month, d);
          final rev = provider.revenueForDate(date);
          revenueByDay[d] = rev;
          totalMonthRevenue += rev;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Export Actions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Laporan Pendapatan Harian',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'csv') {
                        _exportCSV();
                      } else if (value == 'pdf') {
                        _exportPDF();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'csv',
                        child: Row(
                          children: [
                            Icon(Icons.table_chart, size: 20),
                            SizedBox(width: 8),
                            Text('Export CSV'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, size: 20),
                            SizedBox(width: 8),
                            Text('Export PDF'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.download, size: 18, color: AppTheme.surfaceDark),
                          const SizedBox(width: 8),
                          Text('Export', style: GoogleFonts.spaceGrotesk(color: AppTheme.surfaceDark, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // GRAPH CHART SECTION (GRAFIK DI ATAS)
              Builder(
                builder: (context) {
                  final Map<String, int> allRevenueByDate = {};
                  for (final b in provider.bookings) {
                    if (b.paymentStatus == PaymentStatus.lunas) {
                      final dateStr = '${b.date.year}-${b.date.month.toString().padLeft(2, '0')}-${b.date.day.toString().padLeft(2, '0')}';
                      final pkg = dummyPricePackages.firstWhere((p) => p.name == b.psType.bookingDisplayName, orElse: () => dummyPricePackages.first);
                      final priceTier = pkg.prices.firstWhere((t) => t.duration == b.duration.displayName, orElse: () => pkg.prices.first);
                      final revenue = priceTier.price * b.durationHours;
                      allRevenueByDate[dateStr] = (allRevenueByDate[dateStr] ?? 0) + revenue;
                    }
                  }
                  final sortedDates = allRevenueByDate.keys.toList()..sort();
                  final chartDates = sortedDates.length > 7 ? sortedDates.sublist(sortedDates.length - 7) : sortedDates;
                  
                  double maxRevenue = 0;
                  for (final date in chartDates) {
                    if (allRevenueByDate[date]! > maxRevenue) maxRevenue = allRevenueByDate[date]!.toDouble();
                  }
                  maxRevenue = ((maxRevenue / 100000).ceil() * 100000).toDouble();
                  if (maxRevenue == 0) maxRevenue = 100000;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grafik Pendapatan (7 Hari Terakhir)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 250,
                          child: chartDates.isEmpty
                              ? const Center(child: Text('Belum ada data pendapatan'))
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: maxRevenue,
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipColor: (group) => AppTheme.surfaceDark,
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          return BarTooltipItem(
                                            formatRupiah(rod.toY.toInt()),
                                            GoogleFonts.spaceGrotesk(
                                              color: AppTheme.accentCyan,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            if (value.toInt() >= 0 && value.toInt() < chartDates.length) {
                                              final date = chartDates[value.toInt()];
                                              final dayStr = date.substring(8, 10);
                                              final monthStr = date.substring(5, 7);
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  '$dayStr/$monthStr',
                                                  style: const TextStyle(
                                                    color: AppTheme.textMuted,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 50,
                                          getTitlesWidget: (value, meta) {
                                            if (value == 0) return const SizedBox.shrink();
                                            return Text(
                                              '${(value / 1000).toInt()}k',
                                              style: const TextStyle(
                                                color: AppTheme.textMuted,
                                                fontSize: 10,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: maxRevenue / 4,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: AppTheme.dividerColor.withValues(alpha: 0.5),
                                        strokeWidth: 1,
                                        dashArray: [5, 5],
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: List.generate(chartDates.length, (index) {
                                      final date = chartDates[index];
                                      final revenue = allRevenueByDate[date]!.toDouble();
                                      
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: revenue,
                                            color: AppTheme.accentCyan,
                                            width: 22,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                            ),
                                            backDrawRodData: BackgroundBarChartRodData(
                                              show: true,
                                              toY: maxRevenue,
                                              color: AppTheme.surfaceDark.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Total month revenue
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentTeal.withValues(alpha: 0.15),
                      AppTheme.accentCyan.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendapatan ${_monthNames[month]} $year',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatRupiah(totalMonthRevenue),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentTeal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.dividerColor),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        int qris = 0, cash = 0, tf = 0;
                        final bookings = provider.bookingsForMonth(year, month);
                        for (final b in bookings) {
                          final match = dummyPricePackages.where((p) => p.name == b.psType.bookingDisplayName).toList();
                          int spent = match.isNotEmpty ? match.first.prices.first.price * b.durationHours : 10000 * b.durationHours;
                          if (b.paymentMethod == PaymentMethod.qris) {
                            qris += spent;
                          } else if (b.paymentMethod == PaymentMethod.cash) {
                            cash += spent;
                          } else if (b.paymentMethod == PaymentMethod.transfer) {
                            tf += spent;
                          }
                        }
                        return Row(
                          children: [
                            Expanded(child: _buildMiniMethodBadge('QRIS', qris, AppTheme.accentCyan)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMiniMethodBadge('CASH', cash, AppTheme.accentGreen)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMiniMethodBadge('TRANSFER', tf, AppTheme.accentMagenta)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildCalendarHeader(
                year: year,
                month: month,
                onPrev: () => setState(() {
                  _revenueCalendarMonth = DateTime(year, month - 1);
                  _selectedRevenueDate = null;
                }),
                onNext: () => setState(() {
                  _revenueCalendarMonth = DateTime(year, month + 1);
                  _selectedRevenueDate = null;
                }),
              ),
              const SizedBox(height: 16),
              _buildCalendarGrid(
                year: year,
                month: month,
                selectedDate: _selectedRevenueDate,
                onDateTap: (date) {
                  setState(() {
                    if (_selectedRevenueDate != null &&
                        _selectedRevenueDate!.day == date.day &&
                        _selectedRevenueDate!.month == date.month) {
                      _selectedRevenueDate = null;
                    } else {
                      _selectedRevenueDate = date;
                    }
                  });
                },
                cellBuilder: (day) {
                  final rev = revenueByDay[day] ?? 0;
                  if (rev == 0) return const SizedBox.shrink();
                  String label;
                  if (rev >= 1000000) {
                    label = '${(rev / 1000000).toStringAsFixed(1)}jt';
                  } else if (rev >= 1000) {
                    label = '${(rev / 1000).toStringAsFixed(0)}rb';
                  } else {
                    label = '$rev';
                  }
                  return Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentTeal,
                    ),
                  );
                },
              ),
              if (_selectedRevenueDate != null) ...[
                const SizedBox(height: 20),
                _buildRevenueDetailForDate(provider, _selectedRevenueDate!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniMethodBadge(String title, int amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatRupiah(amount),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueDetailForDate(BookingProvider provider, DateTime date) {
    final bookings = provider.bookingsForDate(date);
    final totalRevenue = provider.revenueForDate(date);
    final dayStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    // Breakdown per console type
    final revenueByType = <ConsoleType, int>{};
    final countByType = <ConsoleType, int>{};
    for (final b in bookings) {
      final pkg = dummyPricePackages.firstWhere(
        (p) => p.name == b.psType.bookingDisplayName,
        orElse: () => dummyPricePackages.first,
      );
      final priceTier = pkg.prices.firstWhere(
        (t) => t.duration == b.duration.displayName,
        orElse: () => pkg.prices.first,
      );
      final rev = priceTier.price * b.durationHours;
      revenueByType[b.psType] = (revenueByType[b.psType] ?? 0) + rev;
      countByType[b.psType] = (countByType[b.psType] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.accentTeal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentTeal.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: AppTheme.accentTeal,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Pendapatan $dayStr',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentTeal,
                ),
              ),
              const Spacer(),
              Text(
                formatRupiah(totalRevenue),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentTeal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Summary cards
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Transaksi',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${bookings.length} sesi',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (revenueByType.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: AppTheme.dividerColor, height: 1),
                const SizedBox(height: 12),
                ...revenueByType.entries.map((entry) {
                  final type = entry.key;
                  final rev = entry.value;
                  final count = countByType[type] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: type == ConsoleType.ps4
                                    ? AppTheme.accentCyan
                                    : type == ConsoleType.ps5
                                    ? AppTheme.accentMagenta
                                    : type == ConsoleType.ps5Vip
                                    ? AppTheme.accentTeal
                                    : AppTheme.accentGreen,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${type.displayName} ($count sesi)',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formatRupiah(rev),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportCSV() async {
    try {
      final provider = context.read<BookingProvider>();
      final bookings = provider.bookings.where((b) => b.paymentStatus == PaymentStatus.lunas);
      final revenueByDate = <String, int>{};
      final countByDate = <String, int>{};
      
      for (final b in bookings) {
        final dateStr = '${b.date.year}-${b.date.month.toString().padLeft(2, '0')}-${b.date.day.toString().padLeft(2, '0')}';
        final pkg = dummyPricePackages.firstWhere((p) => p.name == b.psType.bookingDisplayName, orElse: () => dummyPricePackages.first);
        final priceTier = pkg.prices.firstWhere((t) => t.duration == b.duration.displayName, orElse: () => pkg.prices.first);
        final revenue = priceTier.price * b.durationHours;
        revenueByDate[dateStr] = (revenueByDate[dateStr] ?? 0) + revenue;
        countByDate[dateStr] = (countByDate[dateStr] ?? 0) + 1;
      }
      
      String csvData = 'Tanggal,Total Sesi,Pendapatan (Rp)\n';
      final sortedDates = revenueByDate.keys.toList()..sort();
      for (final date in sortedDates) {
        csvData += '$date,${countByDate[date]},${revenueByDate[date]}\n';
      }
      
      downloadFile(
        bytes: utf8.encode(csvData),
        fileName: 'Laporan_Pendapatan.csv',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV berhasil di-download'), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export CSV: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  Future<void> _exportPDF() async {
    try {
      final provider = context.read<BookingProvider>();
      final bookings = provider.bookings.where((b) => b.paymentStatus == PaymentStatus.lunas);
      final revenueByDate = <String, int>{};
      final countByDate = <String, int>{};
      
      for (final b in bookings) {
        final dateStr = '${b.date.year}-${b.date.month.toString().padLeft(2, '0')}-${b.date.day.toString().padLeft(2, '0')}';
        final pkg = dummyPricePackages.firstWhere((p) => p.name == b.psType.bookingDisplayName, orElse: () => dummyPricePackages.first);
        final priceTier = pkg.prices.firstWhere((t) => t.duration == b.duration.displayName, orElse: () => pkg.prices.first);
        final revenue = priceTier.price * b.durationHours;
        revenueByDate[dateStr] = (revenueByDate[dateStr] ?? 0) + revenue;
        countByDate[dateStr] = (countByDate[dateStr] ?? 0) + 1;
      }
      
      final pdf = pw.Document();
      final sortedDates = revenueByDate.keys.toList()..sort((a, b) => b.compareTo(a));
      
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Laporan Pendapatan Harian - Timeless PS', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['Tanggal', 'Total Sesi', 'Pendapatan (Rp)'],
                    ...sortedDates.map((date) => [
                      date,
                      countByDate[date].toString(),
                      formatRupiah(revenueByDate[date]!).replaceAll('Rp', '').trim(),
                    ]),
                  ],
                ),
              ],
            );
          },
        ),
      );
      
      final pdfBytes = await pdf.save();
      downloadFile(
        bytes: pdfBytes,
        fileName: 'Laporan_Pendapatan.pdf',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF berhasil di-download'), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export PDF: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════
  //  SHARED: Calendar widgets
  // ════════════════════════════════════════════════════════

  Widget _buildCalendarHeader({
    required int year,
    required int month,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Year on left
          Text(
            '$year',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMuted,
            ),
          ),
          // Month name + navigation on right
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
                onPressed: onPrev,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              Text(
                _monthNames[month],
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentCyan,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
                onPressed: onNext,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid({
    required int year,
    required int month,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateTap,
    required Widget Function(int day) cellBuilder,
  }) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Monday = 1, Sunday = 7
    final startWeekday = firstDay.weekday; // 1-7 (Mon-Sun)
    final today = DateTime.now();

    return GlassPanel(
      padding: const EdgeInsets.all(12),
      borderRadius: 14,
      child: Column(
        children: [
          // Day headers
          Row(
            children: _dayHeaders.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Day cells
          ...List.generate(((startWeekday - 1 + daysInMonth) / 7).ceil(), (
            weekIndex,
          ) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (dayOfWeek) {
                  final dayNumber =
                      weekIndex * 7 + dayOfWeek - (startWeekday - 2);
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 52));
                  }

                  final cellDate = DateTime(year, month, dayNumber);
                  final isToday =
                      cellDate.day == today.day &&
                      cellDate.month == today.month &&
                      cellDate.year == today.year;
                  final isSelected =
                      selectedDate != null &&
                      selectedDate.day == dayNumber &&
                      selectedDate.month == month &&
                      selectedDate.year == year;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onDateTap(cellDate),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accentCyan.withValues(alpha: 0.2)
                              : isToday
                              ? AppTheme.accentCyan.withValues(alpha: 0.08)
                              : AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accentCyan
                                : isToday
                                ? AppTheme.accentCyan.withValues(alpha: 0.5)
                                : Colors.transparent,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNumber',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: isToday || isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isToday
                                    ? AppTheme.accentCyan
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            cellBuilder(dayNumber),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAB 4: DATA BOOKING HARI INI
  // ════════════════════════════════════════════════════════

  Widget _buildTodayBookings() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final allBookings = provider
            .bookingsForDate(provider.now)
            .where((b) => !b.isWalkIn)
            .toList();
        // Sort by time
        allBookings.sort((a, b) => a.time.compareTo(b.time));

        if (allBookings.isEmpty) {
          return Center(
            child: Text(
              'Belum ada jadwal hari ini',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: allBookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final b = allBookings[index];
            final isWalkIn = b.id.startsWith('WI-');
            final bookingColor = AppTheme.getBookingColor(b.id);

            return GlassPanel(
              enableBlur: false,
              borderRadius: 12,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Color Indicator Strip
                    Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: bookingColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  b.customerName,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bookingColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    b.assignedUnit,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: bookingColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${b.time} (${b.duration})',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  b.phone,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  isWalkIn
                                      ? Icons.directions_walk
                                      : Icons.language,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isWalkIn ? 'Walk-in' : 'Booking Online',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'ID: ${b.id}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirmDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Booking?',
          style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Data booking akan dihapus permanen dan unit akan kembali tersedia.',
          style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  UNIFIED ADD SESSION / BOOKING DIALOG
  // ════════════════════════════════════════════════════════

  void _showAddSessionDialog(
    BuildContext context, {
    SessionInputMode initialMode = SessionInputMode.walkIn,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    SessionInputMode selectedMode = initialMode;
    ConsoleType selectedPsType = ConsoleType.ps4;
    String? selectedUnitLabel;
    DateTime selectedDate = DateTime.now();
    String selectedTime = '10:00';
    SessionDuration selectedDuration = SessionDuration.jam1;
    PaymentMethod selectedPaymentMethod = PaymentMethod.cash;
    PaymentStatus selectedPaymentStatus = PaymentStatus.lunas;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final provider = context.watch<BookingProvider>();

            final availableUnitLabels = provider.units
                .where((u) => u.psType == selectedPsType && u.isAvailable)
                .map((u) => u.label)
                .toList();

            if (selectedUnitLabel == null ||
                !availableUnitLabels.contains(selectedUnitLabel)) {
              selectedUnitLabel = availableUnitLabels.isNotEmpty
                  ? availableUnitLabels.first
                  : null;
            }

            return Dialog(
              backgroundColor: AppTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.dividerColor),
              ),
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER TOGGLE (WALK-IN vs BOOKING)
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setDialogState(
                                  () => selectedMode = SessionInputMode.walkIn,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedMode == SessionInputMode.walkIn
                                            ? AppTheme.accentGreen.withValues(
                                              alpha: 0.2,
                                            )
                                            : AppTheme.cardDark,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          selectedMode == SessionInputMode.walkIn
                                              ? AppTheme.accentGreen
                                              : AppTheme.dividerColor,
                                      width:
                                          selectedMode == SessionInputMode.walkIn
                                              ? 2
                                              : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_walk_rounded,
                                        size: 18,
                                        color:
                                            selectedMode ==
                                                    SessionInputMode.walkIn
                                                ? AppTheme.accentGreen
                                                : AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Walk-in (Main Sekarang)',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            fontWeight:
                                                selectedMode ==
                                                        SessionInputMode.walkIn
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                            color:
                                                selectedMode ==
                                                        SessionInputMode.walkIn
                                                    ? AppTheme.textPrimary
                                                    : AppTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setDialogState(
                                  () => selectedMode = SessionInputMode.booking,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedMode == SessionInputMode.booking
                                            ? AppTheme.accentMagenta.withValues(
                                              alpha: 0.2,
                                            )
                                            : AppTheme.cardDark,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          selectedMode ==
                                                  SessionInputMode.booking
                                              ? AppTheme.accentMagenta
                                              : AppTheme.dividerColor,
                                      width:
                                          selectedMode ==
                                                  SessionInputMode.booking
                                              ? 2
                                              : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 16,
                                        color:
                                            selectedMode ==
                                                    SessionInputMode.booking
                                                ? AppTheme.accentMagenta
                                                : AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Jadwal Booking',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            fontWeight:
                                                selectedMode ==
                                                        SessionInputMode.booking
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                            color:
                                                selectedMode ==
                                                        SessionInputMode.booking
                                                    ? AppTheme.textPrimary
                                                    : AppTheme.textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // NAMA PELANGGAN (WAJIB / REQUIRED)
                        Text(
                          'NAMA PELANGGAN',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameController,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Nama Pelanggan (Wajib diisi)',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama pelanggan wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // NOMOR TELEPON (OPSIONAL)
                        Text(
                          'NOMOR HP / WA (OPSIONAL)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: '08xxxxxxxxxx (Tidak wajib)',
                          ),
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final clean = v.trim();
                              if (!RegExp(r'^[0-9+\-\s()]{8,16}$').hasMatch(clean)) {
                                return 'Format nomor HP tidak valid (misal: 08123456789)';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // DYNAMIC FIELDS BASED ON MODE
                        if (selectedMode == SessionInputMode.walkIn) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TIPE KONSOL',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<ConsoleType>(
                                      isExpanded: true,
                                      initialValue: selectedPsType,
                                      dropdownColor: AppTheme.cardDark,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      items:
                                          ConsoleType.values
                                              .map(
                                                (t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t.displayName),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() {
                                            selectedPsType = val;
                                            selectedUnitLabel = null;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PILIH UNIT (KOSONG)',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: selectedUnitLabel,
                                      dropdownColor: AppTheme.cardDark,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      items:
                                          availableUnitLabels.isEmpty
                                              ? [
                                                const DropdownMenuItem(
                                                  value: null,
                                                  child: Text(
                                                    'Semua Penuh',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ]
                                              : availableUnitLabels
                                                  .map(
                                                    (u) => DropdownMenuItem(
                                                      value: u,
                                                      child: Text(u),
                                                    ),
                                                  )
                                                  .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(
                                            () => selectedUnitLabel = val,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'DURASI MAIN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<SessionDuration>(
                            isExpanded: true,
                            initialValue: selectedDuration,
                            dropdownColor: AppTheme.cardDark,
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items:
                                SessionDuration.values
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(d.displayName),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedDuration = val);
                              }
                            },
                          ),
                        ] else ...[
                          // BOOKING MODE
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TIPE KONSOL',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<ConsoleType>(
                                      isExpanded: true,
                                      initialValue: selectedPsType,
                                      dropdownColor: AppTheme.cardDark,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      items:
                                          ConsoleType.values
                                              .map(
                                                (t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t.displayName),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(
                                            () => selectedPsType = val,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DURASI',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<SessionDuration>(
                                      isExpanded: true,
                                      initialValue: selectedDuration,
                                      dropdownColor: AppTheme.cardDark,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      items:
                                          SessionDuration.values
                                              .map(
                                                (d) => DropdownMenuItem(
                                                  value: d,
                                                  child: Text(d.displayName),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(
                                            () => selectedDuration = val,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // TANGGAL & JAM MULAI
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TANGGAL',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime.now().subtract(
                                            const Duration(days: 30),
                                          ),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 90),
                                          ),
                                        );
                                        if (picked != null) {
                                          setDialogState(
                                            () => selectedDate = picked,
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.cardDark,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppTheme.dividerColor,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(selectedDate),
                                              style: GoogleFonts.spaceGrotesk(
                                                color: AppTheme.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: AppTheme.textMuted,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'JAM MULAI',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedTime,
                                      dropdownColor: AppTheme.cardDark,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                      ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                      items:
                                          getValidTimeSlots(
                                                selectedDuration.hours,
                                              )
                                              .map(
                                                (t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(
                                            () => selectedTime = val,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),

                        // METODE PEMBAYARAN (Cash, QRIS, Transfer)
                        Text(
                          'METODE PEMBAYARAN',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children:
                              PaymentMethod.values.map((m) {
                                bool isSel = selectedPaymentMethod == m;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () => setDialogState(
                                          () => selectedPaymentMethod = m,
                                        ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSel
                                                ? AppTheme.accentCyan.withValues(
                                                  alpha: 0.2,
                                                )
                                                : AppTheme.cardDark,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              isSel
                                                  ? AppTheme.accentCyan
                                                  : AppTheme.dividerColor,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        m.displayName,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight:
                                              isSel
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              isSel
                                                  ? AppTheme.textPrimary
                                                  : AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // STATUS PEMBAYARAN (Lunas / Belum Bayar)
                        Text(
                          'STATUS PEMBAYARAN',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children:
                              PaymentStatus.values.map((s) {
                                bool isSel = selectedPaymentStatus == s;
                                final color =
                                    s == PaymentStatus.lunas
                                        ? AppTheme.accentGreen
                                        : AppTheme.accentMagenta;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () => setDialogState(
                                          () => selectedPaymentStatus = s,
                                        ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSel
                                                ? color.withValues(alpha: 0.2)
                                                : AppTheme.cardDark,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              isSel
                                                  ? color
                                                  : AppTheme.dividerColor,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        s.displayName,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight:
                                              isSel
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color:
                                              isSel
                                                  ? color
                                                  : AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppTheme.dividerColor,
                                  ),
                                  foregroundColor: AppTheme.textSecondary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'Batal',
                                  style: GoogleFonts.spaceGrotesk(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final name = nameController.text.trim();
                                  final phone = phoneController.text.trim();

                                  if (selectedMode == SessionInputMode.walkIn) {
                                    if (selectedUnitLabel == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Pilih unit yang tersedia terlebih dahulu!',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.pop(dialogCtx);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) {
                                        provider.addWalkIn(
                                          baseType: selectedPsType,
                                          unitLabel: selectedUnitLabel!,
                                          playerName: name,
                                          duration: selectedDuration,
                                          paymentMethod: selectedPaymentMethod,
                                          paymentStatus: selectedPaymentStatus,
                                        );
                                      }
                                    });
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppTheme.accentGreen,
                                        content: Text(
                                          'Sesi Walk-in (${selectedPsType.displayName} $selectedUnitLabel) berhasil dimulai!',
                                          style: GoogleFonts.spaceGrotesk(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    final freeUnit = provider.findAvailableUnit(
                                      baseType: selectedPsType,
                                      date: selectedDate,
                                      startTime: selectedTime,
                                      durationHours: selectedDuration.hours,
                                    );

                                    final unitLabel =
                                        freeUnit != null
                                            ? '${selectedPsType.displayName} ${freeUnit.label}'
                                            : '${selectedPsType.displayName} Unit 1';

                                    final booking = Booking(
                                      id:
                                          'BK-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}',
                                      customerName: name,
                                      phone: phone,
                                      psType: selectedPsType,
                                      date: selectedDate,
                                      time: selectedTime,
                                      duration: selectedDuration,
                                      assignedUnit: unitLabel,
                                      paymentMethod: selectedPaymentMethod,
                                      paymentStatus: selectedPaymentStatus,
                                    );

                                    Navigator.pop(dialogCtx);
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      if (mounted) {
                                        provider.addBooking(booking);
                                      }
                                    });

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppTheme.accentGreen,
                                        content: Text(
                                          'Booking berhasil disimpan! ($unitLabel - ${selectedPaymentMethod.displayName})',
                                          style: GoogleFonts.spaceGrotesk(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedMode == SessionInputMode.walkIn
                                          ? AppTheme.accentGreen
                                          : AppTheme.accentMagenta,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  selectedMode == SessionInputMode.walkIn
                                      ? 'Mulai Main'
                                      : 'Simpan Booking',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
