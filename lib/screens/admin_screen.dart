import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/booking_provider.dart';
import '../data/dummy_data.dart';
import '../models/ps_unit.dart';
import '../widgets/section_title.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
              Tab(text: 'Semua Booking'),
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
                          backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.2),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
        final grouped = <String, List<UnitStatus>>{};
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
                  type,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentCyan,
                  ),
                ),
                const SizedBox(height: 12),
                ...units.map((u) => _buildTimelineRow(u)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineRow(UnitStatus unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Row(
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
                            unit.isWalkIn ? Icons.directions_walk : Icons.book_online,
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
          if (!unit.isAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'IN USE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TAB 3: BOOKINGS
  // ════════════════════════════════════════════════════════

  Widget _buildBookingList() {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final allBookings = provider.bookings.reversed.toList(); // newest first
        if (allBookings.isEmpty) {
          return Center(
            child: Text(
              'Belum ada booking',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: allBookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final b = allBookings[index];
            final isWalkIn = b.id.startsWith('WI-');
            return Dismissible(
              key: Key(b.id),
              direction: DismissDirection.endToStart,
              background: Container(
                padding: const EdgeInsets.only(right: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              confirmDismiss: (direction) => _confirmDeleteDialog(context),
              onDismissed: (direction) {
                provider.removeBooking(b.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking ${b.customerName} dihapus'),
                    backgroundColor: AppTheme.accentRed,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isWalkIn 
                            ? AppTheme.accentGreen.withValues(alpha: 0.1)
                            : AppTheme.accentCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isWalkIn ? Icons.directions_walk : Icons.confirmation_number,
                        color: isWalkIn ? AppTheme.accentGreen : AppTheme.accentCyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  b.customerName,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${b.date.day}/${b.date.month}/${b.date.year}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${b.assignedUnit} • ${b.time} (${b.duration})',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (!isWalkIn && b.phone != '-') ...[
                            const SizedBox(height: 4),
                            Text(
                              b.phone,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ],
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
            child: Text('Batal', style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.spaceGrotesk(color: AppTheme.accentRed)),
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
    String? selectedType = 'PS5';
    String? selectedUnitLabel;
    String selectedDuration = '1 Jam';

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

            if (selectedUnitLabel == null || !availableUnitLabels.contains(selectedUnitLabel)) {
              selectedUnitLabel = availableUnitLabels.isNotEmpty ? availableUnitLabels.first : null;
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
                      style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Nama Pelanggan',
                        labelStyle: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
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
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      dropdownColor: AppTheme.cardDark,
                      decoration: InputDecoration(
                        labelText: 'Tipe PS',
                        labelStyle: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentGreen),
                        ),
                      ),
                      items: ['PS4', 'PS5', 'PS5 VIP', 'Nintendo VIP']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary)),
                              ))
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
                        labelStyle: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentGreen),
                        ),
                      ),
                      items: availableUnitLabels.isEmpty 
                        ? [DropdownMenuItem(value: null, child: Text('Semua Penuh', style: GoogleFonts.spaceGrotesk(color: AppTheme.accentRed)))]
                        : availableUnitLabels
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary)),
                              ))
                          .toList(),
                      onChanged: availableUnitLabels.isEmpty ? null : (val) {
                        setState(() => selectedUnitLabel = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Duration Selection
                    DropdownButtonFormField<String>(
                      initialValue: selectedDuration,
                      dropdownColor: AppTheme.cardDark,
                      decoration: InputDecoration(
                        labelText: 'Durasi',
                        labelStyle: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.dividerColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentGreen),
                        ),
                      ),
                      items: List.generate(5, (index) => '${index + 1} Jam')
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary)),
                              ))
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
                          child: Text('Batal', style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: (selectedUnitLabel == null || nameCtrl.text.trim().isEmpty)
                              ? null
                              : () {
                                  final durInt = int.tryParse(selectedDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
                                  provider.addWalkIn(
                                    baseType: selectedType!,
                                    unitLabel: selectedUnitLabel!,
                                    playerName: nameCtrl.text.trim(),
                                    durationHours: durInt,
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
                          child: Text('Mulai Main', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }
}
