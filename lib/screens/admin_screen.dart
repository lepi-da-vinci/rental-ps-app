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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
              Tab(text: 'Data Booking Hari Ini'),
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
              _buildBookingList(),
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
                      'Estimasi Pemasukan',
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
  //  TAB 3: BOOKINGS
  // ════════════════════════════════════════════════════════

  Widget _buildBookingList() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final allBookings = provider.bookings.toList();
        if (allBookings.isEmpty) {
          return Center(
            child: Text(
              'Belum ada booking',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
            ),
          );
        }

        // Group by date string 'yyyy-MM-dd'
        final grouped = <String, List<Booking>>{};
        for (var b in allBookings) {
          final dateStr = '${b.date.year}-${b.date.month.toString().padLeft(2, '0')}-${b.date.day.toString().padLeft(2, '0')}';
          grouped.putIfAbsent(dateStr, () => []).add(b);
        }

        final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a)); // newest first

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: sortedDates.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final dateStr = sortedDates[index];
            final bookings = grouped[dateStr]!;
            
            // Just for display formatting
            final parts = dateStr.split('-');
            final displayDate = '${parts[2]}/${parts[1]}/${parts[0]}';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: AppTheme.cardDecoration(),
              child: Material(
                type: MaterialType.transparency,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                  title: Text(
                    'Tanggal: $displayDate',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                  subtitle: Text(
                    '${bookings.length} Booking',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  children: bookings.map((b) {
                    final isWalkIn = b.id.startsWith('WI-');
                    return Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Icon(
                        isWalkIn ? Icons.directions_walk : Icons.language,
                        color: isWalkIn ? AppTheme.accentGreen : AppTheme.accentCyan,
                      ),
                      title: Text(
                        b.customerName,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${b.assignedUnit} • ${b.time} (${b.duration})',
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 20),
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
                    ));
                  }).toList(),
                ),
              ),
              ),
            );
          },
        );
      },
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
