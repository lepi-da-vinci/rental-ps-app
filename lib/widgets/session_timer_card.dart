import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ps_unit.dart';
import '../models/booking.dart';

/// A card widget that displays a live countdown timer for an active PS unit session.
///
/// Shows player name, console type, time range, and a real-time countdown.
/// Color-coded: green (active) → yellow (≤10min) → red blinking (overtime).
class SessionTimerCard extends StatelessWidget {
  final UnitStatus unit;
  final Booking? activeBooking;
  final int? remainingSeconds;
  final SessionTimerStatus timerStatus;
  final VoidCallback? onExtend;
  final VoidCallback? onFinish;

  const SessionTimerCard({
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

  String get _statusLabel {
    switch (timerStatus) {
      case SessionTimerStatus.overtime:
        return 'OVERTIME';
      case SessionTimerStatus.expiringSoon:
        return 'HAMPIR HABIS';
      case SessionTimerStatus.active:
        return 'AKTIF';
      case SessionTimerStatus.available:
        return 'TERSEDIA';
    }
  }

  double get _progress {
    if (activeBooking == null || remainingSeconds == null) return 0;
    final totalSec = activeBooking!.durationHours * 3600;
    final elapsed = totalSec - remainingSeconds!;
    return (elapsed / totalSec).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.timerStatusColor(timerStatus);
    final isOvertime = timerStatus == SessionTimerStatus.overtime;
    final isExpiring = timerStatus == SessionTimerStatus.expiringSoon;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: isOvertime ? 0.6 : 0.3),
          width: isOvertime ? 2 : 1,
        ),
        boxShadow: (isOvertime || isExpiring)
            ? AppTheme.neonShadow(statusColor, blur: 12, spread: 0)
            : null,
      ),
      child: Column(
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                // Unit badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unit.label.replaceAll('Unit ', '#').replaceAll('Ruang ', 'R'),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${unit.label} (${unit.psType.displayName})',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            unit.isWalkIn
                                ? Icons.directions_walk
                                : Icons.book_online,
                            size: 12,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${unit.playerName ?? 'Unknown'} · ${unit.startTime ?? ''} - ${unit.endTime ?? ''}',
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
                // Status badge
                _StatusBadge(label: _statusLabel, color: statusColor, blink: isOvertime),
              ],
            ),
          ),

          // ── Timer Body ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                // Countdown display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOvertime ? Icons.warning_amber_rounded : Icons.timer_outlined,
                      color: statusColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      remainingSeconds != null
                          ? _formatCountdown(remainingSeconds!)
                          : '--:--',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 22,
                        color: statusColor,
                        shadows: (isOvertime || isExpiring)
                            ? AppTheme.neonShadow(statusColor, blur: 6, offset: Offset.zero)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress bar
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: AppTheme.neonShadow(
                          statusColor,
                          blur: 4,
                          spread: 0,
                          offset: Offset.zero,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Time labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mulai: ${unit.startTime ?? '-'}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      'Selesai: ${unit.endTime ?? '-'}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Action Buttons ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onExtend,
                    icon: const Icon(Icons.add_alarm, size: 16),
                    label: Text(
                      'Perpanjang +1 Jam',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentCyan,
                      side: const BorderSide(color: AppTheme.accentCyan),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onFinish,
                    icon: const Icon(Icons.stop_circle_outlined, size: 16),
                    label: Text(
                      'Selesaikan',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentRed,
                      side: const BorderSide(color: AppTheme.accentRed),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
  }
}

/// Animated status badge that optionally blinks for overtime.
class _StatusBadge extends StatefulWidget {
  final String label;
  final Color color;
  final bool blink;

  const _StatusBadge({
    required this.label,
    required this.color,
    this.blink = false,
  });

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.blink) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blink && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.blink && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: widget.blink ? _opacity.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              widget.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
