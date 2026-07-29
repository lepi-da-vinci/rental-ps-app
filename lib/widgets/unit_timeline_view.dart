import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';

class UnitTimelineView extends StatefulWidget {
  final List<Booking> unitBookings;
  final int startOpHour;
  final int endOpHour;
  final String dateTitle;

  const UnitTimelineView({
    super.key,
    required this.unitBookings,
    required this.startOpHour,
    required this.endOpHour,
    required this.dateTitle,
  });

  @override
  State<UnitTimelineView> createState() => _UnitTimelineViewState();
}

class _UnitTimelineViewState extends State<UnitTimelineView> {
  int? _selectedHour;

  @override
  Widget build(BuildContext context) {
    Booking? selectedBooking;
    if (_selectedHour != null) {
      for (final b in widget.unitBookings) {
        final bStart = int.tryParse(b.time.split(':')[0]) ?? 0;
        final bEnd = bStart + b.durationHours;
        if (_selectedHour! >= bStart && _selectedHour! < bEnd) {
          selectedBooking = b;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jadwal Hari Ini (${widget.dateTitle})',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            if (_selectedHour != null)
              GestureDetector(
                onTap: () => setState(() => _selectedHour = null),
                child: Text(
                  'Tutup Info ✕',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentCyan,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.endOpHour - widget.startOpHour, (index) {
              final h = widget.startOpHour + index;

              // Check if any booking overlaps with this hour
              Booking? matchedBooking;
              for (final b in widget.unitBookings) {
                final bStart = int.tryParse(b.time.split(':')[0]) ?? 0;
                final dur = b.durationHours;
                final bEnd = bStart + dur;
                if (h >= bStart && h < bEnd) {
                  matchedBooking = b;
                  break;
                }
              }

              final isBooked = matchedBooking != null;
              final isWalkIn = matchedBooking?.id.startsWith('WI-') ?? false;
              final isSelected = _selectedHour == h;

              String tooltipMsg = 'Kosong';
              if (matchedBooking != null) {
                final b = matchedBooking;
                tooltipMsg = '${b.customerName} (${b.time} - ${b.endTime})';
              }

              Color blockColor = AppTheme.surfaceDark;
              Color borderColor = AppTheme.dividerColor;
              if (isBooked) {
                final bookingColor = AppTheme.getBookingColor(
                  matchedBooking.id,
                );
                blockColor = bookingColor.withValues(alpha: 0.15);
                borderColor = bookingColor;
              }

              if (isSelected) {
                borderColor = AppTheme.accentCyan;
                blockColor = AppTheme.accentCyan.withValues(alpha: 0.25);
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedHour == h) {
                      _selectedHour = null;
                    } else {
                      _selectedHour = h;
                    }
                  });
                },
                child: Tooltip(
                  message: tooltipMsg,
                  preferBelow: false,
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${h.toString().padLeft(2, '0')}:00',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isBooked || isSelected
                                ? AppTheme.textPrimary
                                : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          isBooked
                              ? (isWalkIn
                                  ? Icons.directions_walk
                                  : Icons.person)
                              : Icons.check_circle_outline,
                          size: 14,
                          color: isBooked
                              ? AppTheme.getBookingColor(matchedBooking.id)
                              : AppTheme.textMuted.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (_selectedHour != null) ...[
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selectedBooking != null
                  ? AppTheme.accentCyan.withValues(alpha: 0.15)
                  : AppTheme.accentGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedBooking != null
                    ? AppTheme.accentCyan
                    : AppTheme.accentGreen,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedBooking != null
                      ? (selectedBooking.isWalkIn
                          ? Icons.directions_walk
                          : Icons.person)
                      : Icons.check_circle_outline,
                  size: 18,
                  color: selectedBooking != null
                      ? AppTheme.accentCyan
                      : AppTheme.accentGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedBooking != null
                            ? 'Sesi Disewa: ${selectedBooking.customerName}'
                            : 'Jam ${_selectedHour.toString().padLeft(2, '0')}:00 - ${(_selectedHour! + 1).toString().padLeft(2, '0')}:00 Kosong',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (selectedBooking != null) ...[
                        Text(
                          'Waktu: ${selectedBooking.time} - ${selectedBooking.endTime} • Tipe: ${selectedBooking.isWalkIn ? 'Walk-in (Langsung)' : 'Booking Online'}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.accentCyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.sports_esports, size: 12, color: AppTheme.accentCyan),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Game Dimainkan: ${_resolveGameName(selectedBooking)}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentCyan,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _resolveGameName(Booking b) {
    if (b.playedGame != null && b.playedGame!.isNotEmpty) return b.playedGame!;

    final ps5List = const [
      'Spider-Man 2',
      'Tekken 8',
      'God of War Ragnarok',
      'EA FC 24',
      'Black Myth: Wukong',
      'Mortal Kombat 1',
      'Gran Turismo 7',
      'Elden Ring',
      'Resident Evil Village',
      'Cyberpunk 2077',
      'eFootball 2024',
    ];

    final ps4List = const [
      'Resident Evil 4 Remake',
      'GTA V',
      'Tekken 7',
      'God of War',
      'The Last of Us Part II',
      'Naruto Storm 4',
      'Red Dead Redemption 2',
      'eFootball 2024',
      'EA FC 24',
      'Mortal Kombat 11',
    ];

    final nintendoList = const [
      'Mario Kart 8 Deluxe',
      'Super Smash Bros. Ultimate',
      'Overcooked! All You Can Eat',
      'Mario Party Superstars',
      'Zelda: Tears of the Kingdom',
    ];

    final hash = b.id.hashCode.abs();
    if (b.psType == ConsoleType.nintendoVip) {
      return nintendoList[hash % nintendoList.length];
    } else if (b.psType == ConsoleType.ps5Vip || b.psType == ConsoleType.ps5) {
      return ps5List[hash % ps5List.length];
    } else {
      return ps4List[hash % ps4List.length];
    }
  }
}
