import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../models/enums.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/section_title.dart';
import '../widgets/retro_button.dart';
import '../utils/time_helpers.dart';
import '../widgets/glass_panel.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';

class BookingScreen extends StatefulWidget {
  final String? initialGame;
  final ConsoleType? initialConsoleType;

  const BookingScreen({
    super.key,
    this.initialGame,
    this.initialConsoleType,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  ConsoleType? _selectedPsType;
  DateTime? _selectedDate;
  String? _selectedTime;
  SessionDuration? _selectedDuration;
  String? _selectedGame;

  List<ConsoleType> get _psTypes => ConsoleType.values;

  @override
  void initState() {
    super.initState();
    if (widget.initialGame != null) {
      _selectedGame = widget.initialGame;
    }
    if (widget.initialConsoleType != null) {
      _selectedPsType = widget.initialConsoleType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BookingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialGame != null &&
        widget.initialGame != oldWidget.initialGame) {
      setState(() {
        _selectedGame = widget.initialGame;
        _selectedPsType = widget.initialConsoleType;
      });
    }
  }

  // Get estimated price based on selection
  String? get _estimatedPrice {
    if (_selectedPsType == null || _selectedDuration == null) return null;
    final durHours = _selectedDuration!.hours;
    // Find matching package tier
    final match = dummyPricePackages
        .where((p) => p.name == _selectedPsType!.bookingDisplayName)
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

  Future<void> _showGamePickerSheet(List<String> games) async {
    String searchQuery = '';
    String? tempSelected = _selectedGame;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = games
                .where((g) =>
                    g.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.92,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28)),
                    border: Border.all(
                        color: AppTheme.accentCyan.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentCyan.withValues(alpha: 0.1),
                        blurRadius: 30,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentCyan.withValues(alpha: 0.2),
                                    AppTheme.accentMagenta
                                        .withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppTheme.accentCyan
                                        .withValues(alpha: 0.4)),
                              ),
                              child: const Icon(Icons.videogame_asset_rounded,
                                  color: AppTheme.accentCyan, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pilih Game',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${games.length} game tersedia',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (tempSelected != null)
                              GestureDetector(
                                onTap: () {
                                  setSheetState(() => tempSelected = null);
                                  setState(() => _selectedGame = null);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentMagenta
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppTheme.accentMagenta
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    'Reset',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.accentMagenta,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Search field
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: TextField(
                          autofocus: false,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Cari game...',
                            hintStyle: GoogleFonts.spaceGrotesk(
                                color: AppTheme.textMuted, fontSize: 14),
                            prefixIcon: const Icon(Icons.search,
                                color: AppTheme.textMuted, size: 20),
                            filled: true,
                            fillColor: AppTheme.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppTheme.dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppTheme.dividerColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppTheme.accentCyan),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          onChanged: (v) =>
                              setSheetState(() => searchQuery = v),
                        ),
                      ),
                      const Divider(
                          height: 1, color: AppTheme.dividerColor),
                      // Game grid
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.search_off,
                                        color: AppTheme.textMuted, size: 40),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Game tidak ditemukan',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppTheme.textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                    16, 16, 16, 32),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 3.2,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final game = filtered[index];
                                  final isSelected = tempSelected == game;
                                  return GestureDetector(
                                    onTap: () {
                                      setSheetState(
                                          () => tempSelected = game);
                                      setState(
                                          () => _selectedGame = game);
                                      HapticFeedback.lightImpact();
                                      Future.delayed(
                                          const Duration(milliseconds: 160),
                                          () {
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  AppTheme.accentCyan
                                                      .withValues(alpha: 0.25),
                                                  AppTheme.accentMagenta
                                                      .withValues(alpha: 0.15),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : AppTheme.cardDark,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.accentCyan
                                              : AppTheme.dividerColor,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.accentCyan
                                                      .withValues(alpha: 0.25),
                                                  blurRadius: 10,
                                                )
                                              ]
                                            : null,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? Icons.check_circle_rounded
                                                : Icons
                                                    .videogame_asset_outlined,
                                            size: 16,
                                            color: isSelected
                                                ? AppTheme.accentCyan
                                                : AppTheme.textMuted,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              game,
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.spaceGrotesk(
                                                fontSize: 12,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppTheme.textPrimary
                                                    : AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
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
            const SizedBox(height: 20),

            // Visual Progress Stepper Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentMagenta,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '1',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Form Booking',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppTheme.accentMagenta.withValues(alpha: 0.5),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '2',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pilih Pembayaran',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                bool isLarge = constraints.maxWidth > 800;

                Widget formContent = GlassPanel(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('NAMA LENGKAP'),
                      const SizedBox(height: 8),
                      Autocomplete<Customer>(
                        displayStringForOption: (Customer option) => option.name,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<Customer>.empty();
                          }
                          final customers = context.read<BookingProvider>().customers;
                          return customers.where((Customer option) {
                            return option.name
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (Customer selection) {
                          _nameController.text = selection.name;
                          _phoneController.text = selection.phone;
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                          textEditingController.addListener(() {
                            if (_nameController.text != textEditingController.text) {
                              _nameController.text = textEditingController.text;
                            }
                          });
                          
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Nama kamu',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Wajib diisi'
                                : null,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              color: AppTheme.backgroundDark,
                              borderRadius: BorderRadius.circular(12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final Customer option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () {
                                        onSelected(option);
                                        // Update internal controller
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          '${option.name} (${option.displayPhone})',
                                          style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('NOMOR WHATSAPP'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: '08xxxxxxxxxx',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nomor WhatsApp wajib diisi';
                          }
                          final clean = v.trim();
                          if (!RegExp(r'^[0-9+\-\s()]{8,16}$').hasMatch(clean)) {
                            return 'Format nomor WA tidak valid (misal: 08123456789)';
                          }
                          return null;
                        },
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
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedPsType = type;
                                _selectedGame = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              width: isLarge
                                  ? (constraints.maxWidth - 400 - 48 - 24) / 3
                                  : (constraints.maxWidth - 96) / 2,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              transform: isSelected
                                  ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
                                  : Matrix4.identity(),
                              transformAlignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accentMagenta.withValues(
                                        alpha: 0.1,
                                      )
                                    : AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.accentMagenta
                                      : AppTheme.dividerColor,
                                ),
                                boxShadow: isSelected
                                    ? AppTheme.neonShadow(
                                        AppTheme.accentMagenta,
                                        spread: 0,
                                        blur: 12,
                                      )
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    type == ConsoleType.nintendoVip
                                        ? Icons.gamepad
                                        : Icons.sports_esports,
                                    color: isSelected
                                        ? AppTheme.textPrimary
                                        : AppTheme.textMuted,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      type.bookingDisplayName,
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      maxLines: 2,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? AppTheme.textPrimary
                                            : AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _selectedPsType == null
                            ? const SizedBox.shrink()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('GAME YANG INGIN DIMAINKAN (OPSIONAL)'),
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (context) {
                                      final provider = context.watch<BookingProvider>();
                                      final matchingUnits = provider.units
                                          .where((u) => u.psType == _selectedPsType)
                                          .toList();
                                      final Set<String> gameSet = {};
                                      for (final u in matchingUnits) {
                                        gameSet.addAll(u.installedGames);
                                      }
                                      final games = gameSet.toList()..sort();

                                      return GestureDetector(
                                        onTap: () => _showGamePickerSheet(games),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                            gradient: _selectedGame != null
                                                ? LinearGradient(
                                                    colors: [
                                                      AppTheme.accentCyan
                                                          .withValues(alpha: 0.08),
                                                      AppTheme.accentMagenta
                                                          .withValues(alpha: 0.05),
                                                    ],
                                                  )
                                                : null,
                                            color: _selectedGame == null
                                                ? AppTheme.surfaceDark
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _selectedGame != null
                                                  ? AppTheme.accentCyan
                                                      .withValues(alpha: 0.7)
                                                  : AppTheme.dividerColor,
                                              width:
                                                  _selectedGame != null ? 1.5 : 1,
                                            ),
                                            boxShadow: _selectedGame != null
                                                ? [
                                                    BoxShadow(
                                                      color: AppTheme.accentCyan
                                                          .withValues(alpha: 0.15),
                                                      blurRadius: 12,
                                                    )
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: _selectedGame != null
                                                      ? AppTheme.accentCyan
                                                          .withValues(alpha: 0.15)
                                                      : AppTheme.cardDark,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  _selectedGame != null
                                                      ? Icons
                                                          .videogame_asset_rounded
                                                      : Icons
                                                          .videogame_asset_outlined,
                                                  size: 18,
                                                  color: _selectedGame != null
                                                      ? AppTheme.accentCyan
                                                      : AppTheme.textMuted,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (_selectedGame != null)
                                                      Text(
                                                        'Game Dipilih',
                                                        style: GoogleFonts
                                                            .spaceGrotesk(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppTheme.accentCyan,
                                                          letterSpacing: 0.8,
                                                        ),
                                                      ),
                                                    Text(
                                                      _selectedGame ??
                                                          'Tap untuk pilih game favorit kamu...',
                                                      style:
                                                          GoogleFonts.spaceGrotesk(
                                                        fontSize: _selectedGame !=
                                                                null
                                                            ? 14
                                                            : 13,
                                                        fontWeight: _selectedGame !=
                                                                null
                                                            ? FontWeight.w700
                                                            : FontWeight.w400,
                                                        color: _selectedGame !=
                                                                null
                                                            ? AppTheme.textPrimary
                                                            : AppTheme.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                _selectedGame != null
                                                    ? Icons.edit_outlined
                                                    : Icons.expand_more_rounded,
                                                color: _selectedGame != null
                                                    ? AppTheme.accentCyan
                                                    : AppTheme.textMuted,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildLabel('DURASI'),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: SessionDuration.values.map((
                                      duration,
                                    ) {
                                      bool isSelected =
                                          _selectedDuration == duration;
                                      return InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            _selectedDuration = duration;
                                            _selectedTime = null;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(24),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppTheme.accentMagenta
                                                      .withValues(alpha: 0.1)
                                                : AppTheme.surfaceDark,
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppTheme.accentMagenta
                                                  : AppTheme.dividerColor,
                                            ),
                                          ),
                                          child: Text(
                                            duration.displayName,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                              color: isSelected
                                                  ? AppTheme.textPrimary
                                                  : AppTheme.textMuted,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('TANGGAL'),
                                            const SizedBox(height: 8),
                                            GestureDetector(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                _pickDate();
                                              },
                                              child: AbsorbPointer(
                                                child: TextFormField(
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                        color: AppTheme
                                                            .textPrimary,
                                                        fontSize: 13,
                                                      ),
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        _selectedDate != null
                                                        ? DateFormat(
                                                            'dd/MM/yyyy',
                                                          ).format(
                                                            _selectedDate!,
                                                          )
                                                        : 'dd/mm/yyyy',
                                                    suffixIcon: const Icon(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      color: AppTheme.textMuted,
                                                      size: 18,
                                                    ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('JAM MULAI'),
                                            const SizedBox(height: 8),
                                            Builder(
                                              builder: (context) {
                                                // Bug 4 fix: only show time slots valid for the chosen duration
                                                final durHours =
                                                    _selectedDuration != null
                                                    ? _selectedDuration!.hours
                                                    : 1;
                                                final validSlots =
                                                    getValidTimeSlots(durHours);
                                                return DropdownButtonFormField<
                                                  String
                                                >(
                                                  initialValue:
                                                      validSlots.contains(
                                                        _selectedTime,
                                                      )
                                                      ? _selectedTime
                                                      : null,
                                                  dropdownColor:
                                                      AppTheme.cardDark,
                                                  style:
                                                      GoogleFonts.spaceGrotesk(
                                                        color: AppTheme
                                                            .textPrimary,
                                                        fontSize: 13,
                                                      ),
                                                  decoration: const InputDecoration(
                                                    hintText: '--:--',
                                                    suffixIcon: Icon(
                                                      Icons
                                                          .access_time_outlined,
                                                      color: AppTheme.textMuted,
                                                      size: 18,
                                                    ),
                                                  ),
                                                  items: validSlots
                                                      .map(
                                                        (t) => DropdownMenuItem(
                                                          value: t,
                                                          child: Text(t),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (v) {
                                                    HapticFeedback.lightImpact();
                                                    setState(
                                                      () => _selectedTime = v,
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                      ),
                    ],
                  ),
                );

                Widget summaryContent = Container(
                  width: isLarge ? 320 : double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme
                        .surfaceDark, // slightly different dark to distinguish
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
                      _buildSummaryRow(
                        'Konsol',
                        _selectedPsType?.bookingDisplayName ?? '-',
                      ),
                      if (_selectedGame != null) ...[
                        const SizedBox(height: 16),
                        _buildSummaryRow(
                          'Game',
                          _selectedGame!,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        'Tanggal',
                        _selectedDate == null ? '-' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        'Jam Mulai',
                        _selectedTime ?? '-',
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                        'Durasi',
                        _selectedDuration?.displayName ?? '-',
                      ),
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
                        backgroundColor: AppTheme
                            .accentMagenta, // Assuming the button is purple/magenta from the UI
                        onPressed: _submitBooking,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Metode pembayaran dipilih pada saat konfirmasi',
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
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitBooking() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedDuration == null) {
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

    final baseType = _selectedPsType!;
    int durationHours = _selectedDuration!.hours;
    SessionDuration effectiveDuration = _selectedDuration!;

    // Check if booking exceeds closing time
    final p = _selectedTime!.split(':');
    final startMins = int.parse(p[0]) * 60 + int.parse(p[1]);

    final todayHours = getOperatingHours().firstWhere(
      (h) => h.isToday,
      orElse: () => getOperatingHours().first,
    );
    final (_, closeHour) = parseOperatingHours(todayHours.hours);
    final closingMins = closeHour * 60;

    if (startMins + durationHours * 60 > closingMins) {
      final maxAllowedHours = (closingMins - startMins) ~/ 60;
      if (maxAllowedHours <= 0) {
        final closeStr = '${closeHour.toString().padLeft(2, '0')}:00';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maaf, sudah terlalu dekat dengan jam tutup ($closeStr)',
              style: GoogleFonts.spaceGrotesk(),
            ),
            backgroundColor: AppTheme.accentRed,
          ),
        );
        return;
      }

      durationHours = maxAllowedHours;
      effectiveDuration = SessionDuration.values.firstWhere(
        (d) => d.hours == maxAllowedHours,
        orElse: () => SessionDuration.jam1,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Batas tutup jam 00:00. Booking otomatis disesuaikan menjadi $maxAllowedHours Jam.',
            style: GoogleFonts.spaceGrotesk(),
          ),
          backgroundColor: AppTheme.accentCyan,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    final provider = context.read<BookingProvider>();

    // 1) Coba cari unit yang BENERAN kosong buat jam+tanggal+durasi ini
    final freeUnit = provider.findAvailableUnit(
      baseType: baseType,
      date: _selectedDate!,
      startTime: _selectedTime!,
      durationHours: durationHours,
    );

    if (freeUnit != null) {
      _createBookingAndShowConfirmation(freeUnit.label, effectiveDuration);
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

  void _createBookingAndShowConfirmation(
    String unitLabel,
    SessionDuration duration,
  ) {
    _showConfirmationDialog(unitLabel, duration);
  }

  /// Dialog kalau slot yang diminta gak muat — kasih 2 opsi ke user.
  void _showConflictDialog({
    required int requestedDuration,
    required int maxDuration,
    required List<ConsoleType> alternatives,
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
                    child: const Icon(
                      Icons.event_busy,
                      color: AppTheme.accentRed,
                      size: 22,
                    ),
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
                          '${_selectedPsType?.bookingDisplayName} jam $_selectedTime buat $requestedDuration jam gak ada unit kosong.',
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
                  title:
                      'Tetap ${_selectedPsType?.bookingDisplayName}, durasi $maxDuration jam',
                  subtitle:
                      'Jam mulai tetap $_selectedTime, cuma durasinya disesuaikan.',
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(
                      () =>
                          _selectedDuration = SessionDuration.values.firstWhere(
                            (e) => e.hours == maxDuration,
                            orElse: () => SessionDuration.jam1,
                          ),
                    );
                    _submitBooking();
                  },
                ),

              // Opsi 2..N: pindah ke tipe lain yang muat durasi penuh
              for (final alt in alternatives) ...[
                const SizedBox(height: 10),
                _conflictOptionTile(
                  icon: Icons.swap_horiz,
                  color: AppTheme.accentMagenta,
                  title: 'Pindah ke ${alt.bookingDisplayName}',
                  subtitle:
                      'Tetap main $requestedDuration jam penuh mulai $_selectedTime.',
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedPsType = alt);
                    _submitBooking();
                  },
                ),
              ],

              if (maxDuration == 0 && alternatives.isEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Semua tipe konsol lagi padat di jam segini. Coba pilih jam lain ya.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
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

  void _showConfirmationDialog(String unitLabel, SessionDuration duration) {
    PaymentMethod selectedPaymentMethod = PaymentMethod.qris;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
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
                      'Pilih metode pembayaran & pastikan data benar.',
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
                          _dialogRow('Nama', _nameController.text.trim()),
                          _dialogRow('No. HP', _phoneController.text.trim().isEmpty ? '-' : _phoneController.text.trim()),
                          _dialogRow('Tipe', _selectedPsType!.bookingDisplayName),
                          _dialogRow(
                            'Unit',
                            '${_selectedPsType!.displayName} $unitLabel',
                            valueColor: AppTheme.accentGreen,
                          ),
                          _dialogRow(
                            'Tanggal',
                            DateFormat('dd MMM yyyy').format(_selectedDate!),
                          ),
                          _dialogRow('Jam', _selectedTime!),
                          _dialogRow('Durasi', duration.displayName),
                          _dialogRow(
                            'Metode',
                            selectedPaymentMethod.displayName,
                            valueColor: AppTheme.accentCyan,
                          ),
                          const Divider(color: AppTheme.dividerColor, height: 16),
                          if (_estimatedPrice != null)
                            _dialogRow(
                              'Harga',
                              _estimatedPrice!,
                              valueColor: AppTheme.accentGreen,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // PILIH METODE PEMBAYARAN IN DIALOG
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PILIH METODE PEMBAYARAN',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PaymentMethod.qris,
                        PaymentMethod.transfer,
                      ].map((method) {
                        bool isSelected = selectedPaymentMethod == method;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedPaymentMethod = method;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.accentCyan.withValues(alpha: 0.15)
                                    : AppTheme.backgroundDark,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppTheme.accentCyan : AppTheme.dividerColor,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  method.displayName,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                                  ),
                                ),
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
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final booking = Booking(
                                id:
                                    'BK-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}',
                                customerName: _nameController.text.trim(),
                                phone: _phoneController.text.trim(),
                                psType: _selectedPsType!,
                                date: _selectedDate!,
                                time: _selectedTime!,
                                duration: duration,
                                assignedUnit: '${_selectedPsType!.displayName} $unitLabel',
                                paymentMethod: selectedPaymentMethod,
                                playedGame: _selectedGame,
                              );

                              context.read<BookingProvider>().addBooking(booking);
                              Navigator.pop(ctx);
                              _resetForm();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.accentGreen,
                                  content: Text(
                                    'Booking berhasil disimpan! (${selectedPaymentMethod.displayName})',
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
                            ),
                            child: Text(
                              'Konfirmasi & Simpan',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w700,
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
          );
        },
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
                    _dialogRow('Tipe', booking.psType.bookingDisplayName),
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
                    _dialogRow('Durasi', booking.duration.displayName),
                    _dialogRow('Metode', booking.paymentMethod.displayName),
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
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                    ),
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
      _selectedGame = null;
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
                  child: GlassPanel(
                    enableBlur: false,
                    padding: const EdgeInsets.all(14),
                    borderRadius: 14,
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

  String _getShortPsType(ConsoleType psType) {
    switch (psType) {
      case ConsoleType.ps4:
        return 'PS4';
      case ConsoleType.ps5:
        return 'PS5';
      case ConsoleType.ps5Vip:
        return 'PS5V';
      case ConsoleType.nintendoVip:
        return 'NIN';
    }
  }
}
