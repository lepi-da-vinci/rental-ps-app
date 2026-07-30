import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ps_unit.dart';
import '../models/booking.dart';
import 'clay_panel.dart';
import 'clay_button.dart';

/// 3D Claymorphism Console Session Unit Card.
class ClayConsoleCard extends StatelessWidget {
  final UnitStatus unit;
  final Booking? activeBooking;
  final int? remainingSeconds;
  final SessionTimerStatus timerStatus;
  final VoidCallback? onExtend;
  final VoidCallback? onFinish;

  const ClayConsoleCard({
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

  Color get _statusColor {
    switch (timerStatus) {
      case SessionTimerStatus.overtime:
        return AppTheme.clayPink;
      case SessionTimerStatus.expiringSoon:
        return AppTheme.clayOrange;
      case SessionTimerStatus.active:
        return AppTheme.clayCyan;
      case SessionTimerStatus.available:
        return AppTheme.clayGreen;
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
    final color = _statusColor;

    return ClayPanel(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      borderColor: color.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Unit Name & Status Badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.sports_esports_rounded, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.label,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
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
              // 3D Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusLabel,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2B2E42), height: 1),
          const SizedBox(height: 16),

          // ── Active Player & Digital 3D Timer Box ──
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
                    const SizedBox(height: 3),
                    Text(
                      activeBooking!.customerName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (activeBooking!.playedGame != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.gamepad_rounded, size: 14, color: AppTheme.clayCyan),
                          const SizedBox(width: 4),
                          Text(
                            activeBooking!.playedGame!,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: AppTheme.clayCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                // 3D Inflated Timer Box
                ClayPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: 18,
                  color: AppTheme.claySurface,
                  borderColor: color.withValues(alpha: 0.6),
                  child: Text(
                    _formatCountdown(remainingSeconds!),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 14,
                      color: color,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── 3D Clay Action Buttons: Tambah Jam & Selesai ──
            Row(
              children: [
                if (onExtend != null)
                  Expanded(
                    child: ClayButton.text(
                      text: 'Tambah Jam',
                      icon: Icons.add_alarm_rounded,
                      color: AppTheme.clayPurple,
                      onTap: onExtend,
                    ),
                  ),
                if (onExtend != null && onFinish != null)
                  const SizedBox(width: 12),
                if (onFinish != null)
                  Expanded(
                    child: ClayButton.text(
                      text: 'Selesaikan',
                      icon: Icons.stop_circle_outlined,
                      color: AppTheme.clayPink,
                      onTap: onFinish,
                    ),
                  ),
              ],
            ),
          ] else ...[
            // Standby Unit Row
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.clayGreen,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Konsol Standby — Siap Digunakan',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
