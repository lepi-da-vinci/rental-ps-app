import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ps_unit.dart';
import '../models/booking.dart';

/// Skeuomorphic 3D PS5 Console Body Card with Realistic LED Status Light Strip.
class SkeuoConsoleCard extends StatelessWidget {
  final UnitStatus unit;
  final Booking? activeBooking;
  final int? remainingSeconds;
  final SessionTimerStatus timerStatus;
  final VoidCallback? onExtend;
  final VoidCallback? onFinish;

  const SkeuoConsoleCard({
    super.key,
    required this.unit,
    required this.activeBooking,
    required this.remainingSeconds,
    required this.timerStatus,
    this.onExtend,
    this.onFinish,
  });

  String _formatCountdown(int seconds) {
    final isNegative = seconds < 0;
    final abs = seconds.abs();
    final h = abs ~/ 3600;
    final m = (abs % 3600) ~/ 60;
    final s = abs % 60;
    final prefix = isNegative ? '+' : '';
    if (h > 0) {
      return '$prefix${h}h ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$prefix${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _ledColor {
    switch (timerStatus) {
      case SessionTimerStatus.overtime:
        return AppTheme.ps5LedCrimson;
      case SessionTimerStatus.expiringSoon:
        return AppTheme.ps5LedOrange;
      case SessionTimerStatus.active:
        return AppTheme.ps5LedBlue;
      case SessionTimerStatus.available:
        return AppTheme.ps5LedActiveGreen;
    }
  }

  String get _statusLabel {
    switch (timerStatus) {
      case SessionTimerStatus.overtime:
        return 'OVERTIME';
      case SessionTimerStatus.expiringSoon:
        return 'HAMPIR HABIS';
      case SessionTimerStatus.active:
        return 'SESI AKTIF';
      case SessionTimerStatus.available:
        return 'STANDBY / TERSEDIA';
    }
  }

  @override
  Widget build(BuildContext context) {
    final led = _ledColor;
    final isOvertime = timerStatus == SessionTimerStatus.overtime;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.ps5ChassisDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        border: Border.all(
          color: led.withValues(alpha: isOvertime ? 0.8 : 0.4),
          width: 2,
        ),
        boxShadow: [
          // LED Chassis Ambient Glow
          BoxShadow(
            color: led.withValues(alpha: 0.3),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          // Physical Chassis Drop Shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 14,
            offset: const Offset(4, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── PS5 LED Indicator Strip Bar ──
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: led,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: led,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Bar: PS5 Console Badge & LED Status ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Console Power LED Lamp Icon
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: led.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: led.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: led.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.power_settings_new_rounded,
                            color: led,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unit.label.toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              unit.psType.bookingDisplayName,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // LED Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: led.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: led.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: led,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: led,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _statusLabel,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: led,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF232738), height: 1),
                const SizedBox(height: 14),

                // ── Active Player & Countdown Timer Display ──
                if (activeBooking != null && remainingSeconds != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GAMER / PEMAIN',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeBooking!.customerName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (activeBooking!.playedGame != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.sports_esports_rounded, size: 13, color: AppTheme.ps5LedBlue),
                                const SizedBox(width: 4),
                                Text(
                                  activeBooking!.playedGame!,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: AppTheme.ps5LedBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Countdown Digital Timer Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: led.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: led.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          _formatCountdown(remainingSeconds!),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 14,
                            color: led,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Action Buttons: Tambah Jam & Selesai ──
                  Row(
                    children: [
                      if (onExtend != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onExtend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.ps5MetallicSlate,
                              foregroundColor: AppTheme.ps5LedBlue,
                              side: BorderSide(color: AppTheme.ps5LedBlue.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.add_alarm_rounded, size: 16),
                            label: Text(
                              'Tambah Jam',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      if (onExtend != null && onFinish != null)
                        const SizedBox(width: 10),
                      if (onFinish != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onFinish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.ps5LedCrimson,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.stop_circle_outlined, size: 16),
                            label: Text(
                              'Selesaikan',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  // Standby Unit Display
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppTheme.ps5LedActiveGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Konsol Siap Digunakan untuk Main / Booking',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
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
    );
  }
}
