import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
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
                      if (selectedBooking != null)
                        Text(
                          'Waktu: ${selectedBooking.time} - ${selectedBooking.endTime} • Tipe: ${selectedBooking.isWalkIn ? 'Walk-in (Langsung)' : 'Booking Online'}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
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
}
