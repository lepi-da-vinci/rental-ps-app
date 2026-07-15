import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';

class UnitTimelineView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Hari Ini ($dateTitle)',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(endOpHour - startOpHour, (index) {
              final h = startOpHour + index;

              // Check if any booking overlaps with this hour
              Booking? matchedBooking;
              for (final b in unitBookings) {
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

              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (isBooked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sesi disewa oleh: $tooltipMsg',
                          style: GoogleFonts.spaceGrotesk(color: Colors.white),
                        ),
                        backgroundColor: AppTheme.cardDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppTheme.dividerColor),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: AppTheme.accentCyan,
                          onPressed: () {},
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Jam ini kosong / tersedia',
                          style: GoogleFonts.spaceGrotesk(color: Colors.white),
                        ),
                        backgroundColor: AppTheme.cardDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppTheme.dividerColor),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Tooltip(
                  message: tooltipMsg,
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${h.toString().padLeft(2, '0')}:00',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isBooked
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
      ],
    );
  }
}
