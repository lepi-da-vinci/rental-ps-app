import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A slide-in alert banner displayed at the top of the admin dashboard
/// when units are expiring soon or already overtime.
class SessionAlertBanner extends StatefulWidget {
  final int expiringCount;
  final int overtimeCount;
  final VoidCallback? onTap;

  const SessionAlertBanner({
    super.key,
    required this.expiringCount,
    required this.overtimeCount,
    this.onTap,
  });

  @override
  State<SessionAlertBanner> createState() => _SessionAlertBannerState();
}

class _SessionAlertBannerState extends State<SessionAlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _hasAlert => widget.expiringCount > 0 || widget.overtimeCount > 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: _hasAlert ? _buildBanner() : const SizedBox.shrink(),
    );
  }

  Widget _buildBanner() {
    final hasOvertime = widget.overtimeCount > 0;
    final bannerColor = hasOvertime ? AppTheme.accentRed : AppTheme.warningYellow;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.08 * _pulseAnimation.value),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: bannerColor.withValues(alpha: 0.4 * _pulseAnimation.value),
                width: 1.5,
              ),
              boxShadow: AppTheme.neonShadow(
                bannerColor,
                blur: 10 * _pulseAnimation.value,
                spread: 0,
                offset: Offset.zero,
              ),
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bannerColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasOvertime ? Icons.warning_amber_rounded : Icons.alarm,
                color: bannerColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasOvertime
                        ? '⚠️ ${widget.overtimeCount} Unit Overtime!'
                        : '⏰ ${widget.expiringCount} Unit Hampir Habis',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: bannerColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasOvertime
                        ? 'Ada ${widget.overtimeCount} unit yang sudah melewati waktu sesi'
                            '${widget.expiringCount > 0 ? ' + ${widget.expiringCount} hampir habis' : ''}'
                        : '${widget.expiringCount} unit tersisa kurang dari 10 menit',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
