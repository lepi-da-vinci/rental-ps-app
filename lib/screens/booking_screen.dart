import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/section_title.dart';
import '../widgets/retro_button.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedPsType;
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedDuration;

  List<String> get _psTypes => ['PS4 Reguler', 'PS5 Reguler', 'PS5 VIP', 'Nintendo VIP'];


  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Get estimated price based on selection
  String? get _estimatedPrice {
    if (_selectedPsType == null || _selectedDuration == null) return null;
    final durHours =
        int.tryParse(_selectedDuration!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    // Find matching package tier
    final match = dummyPricePackages
        .where((p) => p.name == _selectedPsType)
        .toList();
    if (match.isEmpty) return null;
    // Find exact duration match in prices list
    final pkg = match.first;
    final exactPrice = pkg.prices.where((pt) {
      final h =
          int.tryParse(pt.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return h == durHours;
    });
    if (exactPrice.isNotEmpty) return formatRupiah(exactPrice.first.price);
    // Estimate from per-hour of first tier
    return '~${formatRupiah(pkg.prices.first.price * durHours)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Reservasi ',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Konsol',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentMagenta,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Isi form di bawah — tim kami akan konfirmasi ketersediaan dalam 5 menit.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            LayoutBuilder(
              builder: (context, constraints) {
                bool isLarge = constraints.maxWidth > 800;

                Widget formContent = Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('NAMA LENGKAP'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Nama kamu',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildLabel('NOMOR WHATSAPP'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: '08xxxxxxxxxx',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('PILIH KONSOL'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _psTypes.map((type) {
                          bool isSelected = _selectedPsType == type;
                          return InkWell(
                            onTap: () => setState(() => _selectedPsType = type),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: isLarge ? (constraints.maxWidth - 400 - 48 - 24) / 3 : (constraints.maxWidth - 96) / 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.accentMagenta.withValues(alpha: 0.1) : AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppTheme.accentMagenta : AppTheme.dividerColor,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    type.contains('Nintendo') ? Icons.gamepad : Icons.sports_esports,
                                    color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    type,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('DURASI'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: durationOptions.map((duration) {
                          bool isSelected = _selectedDuration == duration;
                          return InkWell(
                            onTap: () => setState(() {
                              _selectedDuration = duration;
                              // Bug 4 fix: reset selected time when duration changes
                              // so the user must re-pick a valid slot
                              _selectedTime = null;
                            }),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.accentMagenta.withValues(alpha: 0.1) : AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? AppTheme.accentMagenta : AppTheme.dividerColor,
                                ),
                              ),
                              child: Text(
                                duration,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('TANGGAL'),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'dd/mm/yyyy',
                                        suffixIcon: const Icon(Icons.calendar_today_outlined, color: AppTheme.textMuted, size: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('JAM MULAI'),
                                const SizedBox(height: 8),
                                Builder(builder: (context) {
                                  // Bug 4 fix: only show time slots valid for the chosen duration
                                  final durHours = _selectedDuration != null
                                     ? int.tryParse(_selectedDuration!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1
                                     : 1;
                                  final validSlots = getValidTimeSlots(durHours);
                                  return DropdownButtonFormField<String>(
                                    initialValue: validSlots.contains(_selectedTime) ? _selectedTime : null,
                                    dropdownColor: AppTheme.cardDark,
                                    style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 13),
                                    decoration: const InputDecoration(
                                      hintText: '--:--',
                                      suffixIcon: Icon(Icons.access_time_outlined, color: AppTheme.textMuted, size: 18),
                                    ),
                                    items: validSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                    onChanged: (v) => setState(() => _selectedTime = v),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                Widget summaryContent = Container(
                  width: isLarge ? 320 : double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark, // slightly different dark to distinguish
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RINGKASAN',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSummaryRow('Konsol', _selectedPsType ?? '-'),
                      const SizedBox(height: 16),
                      _buildSummaryRow('Durasi', _selectedDuration ?? '-'),
                      const SizedBox(height: 16),
                      _buildSummaryRow('Estimasi', _estimatedPrice ?? '-'),
                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.dividerColor),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            _estimatedPrice ?? 'Rp 0',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      RetroButton(
                        label: 'Konfirmasi Booking',
                        isFullWidth: true,
                        backgroundColor: AppTheme.accentMagenta, // Assuming the button is purple/magenta from the UI
                        onPressed: _submitBooking,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Bayar di tempat · Batal gratis sebelum 1 jam',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (isLarge) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: formContent),
                      const SizedBox(width: 24),
                      summaryContent,
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      formContent,
                      const SizedBox(height: 24),
                      summaryContent,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 40),
            // ── History ──
            _buildRecentBookings(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }



  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              onPrimary: AppTheme.textPrimary,
              surface: AppTheme.surfaceDark,
              onSurface: AppTheme.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppTheme.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitBooking() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null || _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lengkapi tanggal, jam mulai, dan durasi dulu ya',
            style: GoogleFonts.spaceGrotesk(),
          ),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final baseType = baseTypeOf(_selectedPsType!);
    final durationHours =
        int.tryParse(_selectedDuration!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final provider = context.read<BookingProvider>();

    // 1) Coba cari unit yang BENERAN kosong buat jam+tanggal+durasi ini
    final freeUnit = provider.findAvailableUnit(
      baseType: baseType,
      date: _selectedDate!,
      startTime: _selectedTime!,
      durationHours: durationHours,
    );

    if (freeUnit != null) {
      _createBookingAndShowConfirmation(freeUnit.label, durationHours);
      return;
    }

    // 2) Gak ada unit yang kosong penuh -> cari solusi buat ditawarin ke user
    final maxDuration = provider.maxAvailableDurationHours(
      baseType: baseType,
      date: _selectedDate!,
      startTime: _selectedTime!,
    );
    final alternatives = provider.findAlternativeTypesForFullDuration(
      excludeType: baseType,
      date: _selectedDate!,
      startTime: _selectedTime!,
      durationHours: durationHours,
    );

    _showConflictDialog(
      requestedDuration: durationHours,
      maxDuration: maxDuration,
      alternatives: alternatives,
    );
  }

  void _createBookingAndShowConfirmation(String unitLabel, int durationHours) {
    final booking = Booking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      psType: _selectedPsType!,
      date: _selectedDate!,
      time: _selectedTime!,
      duration: '$durationHours Jam',
      assignedUnit: '$_selectedPsType $unitLabel',
    );
    _showConfirmationDialog(booking);
  }

  /// Dialog kalau slot yang diminta gak muat — kasih 2 opsi ke user.
  void _showConflictDialog({
    required int requestedDuration,
    required int maxDuration,
    required List<String> alternatives,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_busy, color: AppTheme.accentRed, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Slot Lagi Penuh',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '$_selectedPsType jam $_selectedTime buat $requestedDuration jam gak ada unit kosong.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Opsi 1: tetap booking, durasi dipangkas
              if (maxDuration > 0)
                _conflictOptionTile(
                  icon: Icons.timer_outlined,
                  color: AppTheme.accentCyan,
                  title: 'Tetap $_selectedPsType, durasi $maxDuration jam',
                  subtitle: 'Jam mulai tetap $_selectedTime, cuma durasinya disesuaikan.',
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedDuration = '$maxDuration Jam');
                    _submitBooking();
                  },
                ),

              // Opsi 2..N: pindah ke tipe lain yang muat durasi penuh
              for (final alt in alternatives) ...[
                const SizedBox(height: 10),
                _conflictOptionTile(
                  icon: Icons.swap_horiz,
                  color: AppTheme.accentMagenta,
                  title: 'Pindah ke ${displayNameForBaseType(alt)}',
                  subtitle: 'Tetap main $requestedDuration jam penuh mulai $_selectedTime.',
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedPsType = displayNameForBaseType(alt));
                    _submitBooking();
                  },
                ),
              ],

              if (maxDuration == 0 && alternatives.isEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Semua tipe konsol lagi padat di jam segini. Coba pilih jam lain ya.',
                  style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.dividerColor),
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Batal', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conflictOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 18),
          ],
        ),
      ),
    );
  }


  void _showConfirmationDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 28,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Konfirmasi Booking',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pastikan data di bawah sudah benar.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              // Summary rows
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _dialogRow('Nama', booking.customerName),
                    _dialogRow('No. HP', booking.phone),
                    _dialogRow('Tipe', booking.psType),
                    _dialogRow(
                      'Unit',
                      booking.assignedUnit,
                      valueColor: AppTheme.accentGreen,
                    ),
                    _dialogRow(
                      'Tanggal',
                      DateFormat('dd MMM yyyy').format(booking.date),
                    ),
                    _dialogRow('Jam', booking.time),
                    _dialogRow('Durasi', booking.duration),
                    const Divider(color: AppTheme.dividerColor, height: 16),
                    _dialogRow(
                      'ID',
                      booking.id,
                      valueColor: AppTheme.accentCyan,
                    ),
                    if (_estimatedPrice != null)
                      _dialogRow(
                        'Harga',
                        _estimatedPrice!,
                        valueColor: AppTheme.accentGreen,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.dividerColor),
                        foregroundColor: AppTheme.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<BookingProvider>().addBooking(booking);
                        Navigator.pop(ctx);
                        _resetForm();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.accentGreen,
                            content: Text(
                              'Booking berhasil disimpan!',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accentMagenta.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  size: 28,
                  color: AppTheme.accentMagenta,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Detail Booking',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _dialogRow('Nama', booking.customerName),
                    _dialogRow('No. HP', booking.phone),
                    _dialogRow('Tipe', booking.psType),
                    _dialogRow(
                      'Unit',
                      booking.assignedUnit,
                      valueColor: AppTheme.accentGreen,
                    ),
                    _dialogRow(
                      'Tanggal',
                      DateFormat('dd MMM yyyy').format(booking.date),
                    ),
                    _dialogRow('Jam', booking.time),
                    _dialogRow('Durasi', booking.duration),
                    const Divider(color: AppTheme.dividerColor, height: 16),
                    _dialogRow(
                      'ID',
                      booking.id,
                      valueColor: AppTheme.accentCyan,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.dividerColor),
                    foregroundColor: AppTheme.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: valueColor ?? AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    setState(() {
      _selectedPsType = null;
      _selectedDate = null;
      _selectedTime = null;
      _selectedDuration = null;
    });
  }

  Widget _buildRecentBookings() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        if (provider.bookings.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Riwayat Booking'),
            ...provider.bookings.reversed.take(5).map((b) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _showBookingDetails(b),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppTheme.accentCyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _getShortPsType(b.psType),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentCyan,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.customerName,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${DateFormat('dd MMM yyyy').format(b.date)} · ${b.time} · ${b.duration}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppTheme.textMuted,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
  
  String _getShortPsType(String psType) {
    if (psType.toLowerCase().contains('nintendo')) return 'NIN';
    if (psType.toLowerCase().contains('ps5 vip')) return 'PS5V';
    if (psType.toLowerCase().contains('ps5')) return 'PS5';
    if (psType.toLowerCase().contains('ps4')) return 'PS4';
    return psType;
  }
}
