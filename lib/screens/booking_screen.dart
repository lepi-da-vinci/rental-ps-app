import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/neon_card.dart';
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
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Data Diri ──
            _buildSectionCard(
              title: 'Data Diri',
              icon: Icons.person_outline,
              children: [
                _buildLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama kamu',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildLabel('No. HP / WhatsApp'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: '08xxxxxxxxxx',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'No. HP wajib diisi';
                    }
                    if (v.trim().length < 10) return 'No. HP minimal 10 digit';
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Section 2: Detail Booking ──
            _buildSectionCard(
              title: 'Detail Booking',
              icon: Icons.event_outlined,
              children: [
                _buildLabel('Tipe PlayStation'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPsType,
                  dropdownColor: AppTheme.cardDark,
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Pilih tipe PS',
                    prefixIcon: Icon(
                      Icons.sports_esports_outlined,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  items: _psTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPsType = v),
                  validator: (v) => v == null ? 'Pilih tipe PS' : null,
                ),
                const SizedBox(height: 16),
                // Date & Time in a row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Tanggal'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDate,
                            child: AbsorbPointer(
                              child: TextFormField(
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: _selectedDate != null
                                      ? DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_selectedDate!)
                                      : 'dd/mm/yyyy',
                                  prefixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppTheme.textMuted,
                                    size: 20,
                                  ),
                                ),
                                validator: (_) => _selectedDate == null
                                    ? 'Pilih tanggal'
                                    : null,
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
                          _buildLabel('Jam Mulai'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedTime,
                            dropdownColor: AppTheme.cardDark,
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Jam',
                              prefixIcon: Icon(
                                Icons.access_time_outlined,
                                color: AppTheme.textMuted,
                                size: 20,
                              ),
                            ),
                            items: timeSlotOptions
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _selectedTime = v),
                            validator: (v) => v == null ? 'Pilih jam' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Durasi'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDuration,
                  dropdownColor: AppTheme.cardDark,
                  style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Pilih durasi',
                    prefixIcon: Icon(
                      Icons.hourglass_bottom_outlined,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  items: durationOptions
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDuration = v),
                  validator: (v) => v == null ? 'Pilih durasi' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Estimated price ──
            if (_estimatedPrice != null) ...[
              NeonCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: AppTheme.accentCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Estimasi harga:',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _estimatedPrice!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Submit ──
            RetroButton(
              label: 'Konfirmasi Booking',
              icon: Icons.check_circle_outline,
              isFullWidth: true,
              backgroundColor: AppTheme.accentCyan,
              onPressed: _submitBooking,
            ),
            const SizedBox(height: 28),

            // ── History ──
            _buildRecentBookings(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Section Card wrapper ──
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return NeonCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.accentCyan),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
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

    final baseType = _selectedPsType == 'PS5 VIP' 
        ? 'PS5 VIP' 
        : _selectedPsType == 'Nintendo VIP'
            ? 'Nintendo VIP'
            : (_selectedPsType!.contains('PS4') ? 'PS4' : 'PS5');
    final availableUnits = context.read<BookingProvider>().units
        .where((u) => u.psType == baseType && u.isAvailable)
        .toList();
    final assignedUnit = availableUnits.isNotEmpty
        ? '$_selectedPsType ${availableUnits.first.label}'
        : 'Menunggu Unit Kosong';

    final booking = Booking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      psType: _selectedPsType!,
      date: _selectedDate!,
      time: _selectedTime!,
      duration: _selectedDuration!,
      assignedUnit: assignedUnit,
    );

    _showConfirmationDialog(booking);
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
                  child: NeonCard(
                    padding: const EdgeInsets.all(14),
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
