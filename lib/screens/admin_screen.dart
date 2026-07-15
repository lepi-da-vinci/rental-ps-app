import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../data/dummy_data.dart';
import '../models/ps_unit.dart';
import '../models/enums.dart';
import '../widgets/section_title.dart';
import '../widgets/unit_timeline_view.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calendar state for Data Booking
  late DateTime _bookingCalendarMonth;
  DateTime? _selectedBookingDate;

  // Calendar state for Data Pendapatan
  late DateTime _revenueCalendarMonth;
  DateTime? _selectedRevenueDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final now = DateTime.now();
    _bookingCalendarMonth = DateTime(now.year, now.month);
    _revenueCalendarMonth = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            border: Border(
              bottom: BorderSide(color: AppTheme.dividerColor, width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.accentCyan,
            labelColor: AppTheme.accentCyan,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Timeline Unit'),
              Tab(text: 'Data Booking'),
              Tab(text: 'Data Pendapatan'),
              Tab(text: 'Booking Hari Ini'),
            ],
          ),
        ),
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboard(),
              _buildUnitTimeline(),
              _buildBookingCalendar(),
              _buildRevenueCalendar(),
              _buildTodayBookings(),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAB 1: DASHBOARD
  // ════════════════════════════════════════════════════════

  Widget _buildDashboard() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final stats = provider.todayStats;
        final revenue = provider.todayRevenue;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Ringkasan Hari Ini',
                subtitle: 'Statistik rental untuk hari ini',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Booking',
                      '${stats['totalBookings']}',
                      Icons.book_online,
                      AppTheme.accentMagenta,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Unit Dipakai',
                      '${stats['unitsInUse']}',
                      Icons.videogame_asset,
                      AppTheme.accentCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Unit Kosong',
                      '${stats['unitsAvailable']}',
                      Icons.event_available,
                      AppTheme.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pemasukan Hari Ini',
                      formatRupiah(revenue),
                      Icons.payments_outlined,
                      AppTheme.accentTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Walk-in Quick Action
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.directions_walk,
                            color: AppTheme.accentGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pelanggan Langsung (Walk-in)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan sesi main langsung tanpa booking formal.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showWalkInDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen.withValues(
                            alpha: 0.2,
                          ),
                          foregroundColor: AppTheme.accentGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppTheme.accentGreen),
                          ),
                        ),
                        child: Text(
                          'Tambah Walk-in',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    // assignedUnit format is typically '$psType ${unit.label}' or similar.
    // We check if it ends with the unit label and contains the base psType.
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(),
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
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

    final dayStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: AppTheme.accentCyan, size: 18),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(),
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
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.dividerColor),
              ),
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
                              color: isWalkIn ? AppTheme.accentGreen : AppTheme.accentCyan,
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
                              icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 18),
                              onPressed: () async {
                                final confirm = await _confirmDeleteDialog(context);
                                if (confirm == true) {
                                  provider.removeBooking(b.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Booking ${b.customerName} dihapus'),
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
                  border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
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

  Widget _buildRevenueDetailForDate(BookingProvider provider, DateTime date) {
    final bookings = provider.bookingsForDate(date);
    final totalRevenue = provider.revenueForDate(date);
    final dayStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

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
            border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.payments_outlined, color: AppTheme.accentTeal, size: 18),
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

  // ════════════════════════════════════════════════════════
  //  SHARED: Calendar widgets
  // ════════════════════════════════════════════════════════

  Widget _buildCalendarHeader({
    required int year,
    required int month,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
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
                icon: const Icon(Icons.chevron_left, color: AppTheme.textSecondary, size: 22),
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
                icon: const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 22),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerColor),
      ),
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
          ...List.generate(
            ((startWeekday - 1 + daysInMonth) / 7).ceil(),
            (weekIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: List.generate(7, (dayOfWeek) {
                    final dayNumber = weekIndex * 7 + dayOfWeek - (startWeekday - 2);
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 52));
                    }

                    final cellDate = DateTime(year, month, dayNumber);
                    final isToday = cellDate.day == today.day &&
                        cellDate.month == today.month &&
                        cellDate.year == today.year;
                    final isSelected = selectedDate != null &&
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
            },
          ),
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
        final allBookings = provider.bookingsForDate(provider.now).where((b) => !b.isWalkIn).toList();
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

            return Container(
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor),
              ),
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
  //  WALK-IN DIALOG
  // ════════════════════════════════════════════════════════

  void _showWalkInDialog() {
    final nameCtrl = TextEditingController();
    ConsoleType? selectedType = ConsoleType.ps5;
    String? selectedUnitLabel;
    SessionDuration selectedDuration = SessionDuration.jam1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final provider = context.read<BookingProvider>();

            // Available unit labels for the selected type
            final availableUnitLabels = provider.units
                .where((u) => u.psType == selectedType && u.isAvailable)
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Sesi Walk-in',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name input
                    TextField(
                      controller: nameCtrl,
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nama Pelanggan',
                        labelStyle: GoogleFonts.spaceGrotesk(
                          color: AppTheme.textMuted,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type Selection
                    DropdownButtonFormField<ConsoleType>(
                      initialValue: selectedType,
                      dropdownColor: AppTheme.cardDark,
                      decoration: InputDecoration(
                        labelText: 'Tipe PS',
                        labelStyle: GoogleFonts.spaceGrotesk(
                          color: AppTheme.textMuted,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentGreen),
                        ),
                      ),
                      items: ConsoleType.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.displayName,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedType = val;
                          selectedUnitLabel = null; // reset unit
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unit Selection
                    DropdownButtonFormField<String?>(
                      initialValue: selectedUnitLabel,
                      dropdownColor: AppTheme.cardDark,
                      decoration: InputDecoration(
                        labelText: 'Pilih Unit',
                        labelStyle: GoogleFonts.spaceGrotesk(
                          color: AppTheme.textMuted,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentGreen),
                        ),
                      ),
                      items: availableUnitLabels.isEmpty
                          ? [
                              DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'Semua Penuh',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ),
                            ]
                          : availableUnitLabels
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      onChanged: availableUnitLabels.isEmpty
                          ? null
                          : (val) {
                              setState(() => selectedUnitLabel = val);
                            },
                    ),
                    const SizedBox(height: 16),

                    // Duration Selection
                    DropdownButtonFormField<SessionDuration>(
                      initialValue: selectedDuration,
                      dropdownColor: AppTheme.cardDark,
                      decoration: InputDecoration(
                        labelText: 'Durasi',
                        labelStyle: GoogleFonts.spaceGrotesk(
                          color: AppTheme.textMuted,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentGreen),
                        ),
                      ),
                      items: SessionDuration.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.displayName,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedDuration = val);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed:
                              (selectedUnitLabel == null ||
                                  nameCtrl.text.trim().isEmpty)
                              ? null
                              : () {
                                  provider.addWalkIn(
                                    baseType: selectedType!,
                                    unitLabel: selectedUnitLabel!,
                                    playerName: nameCtrl.text.trim(),
                                    duration: selectedDuration,
                                  );
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Walk-in ditambahkan'),
                                      backgroundColor: AppTheme.accentGreen,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Mulai Main',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
}
