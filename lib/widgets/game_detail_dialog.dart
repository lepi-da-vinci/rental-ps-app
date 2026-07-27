import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ps_unit.dart';
import '../theme/app_theme.dart';
import 'glass_panel.dart';
import 'retro_button.dart';

/// Modal dialog showing rich details and description for a selected game.
class GameDetailDialog extends StatelessWidget {
  final GameItem game;
  final Function(int)? onNavigateToBooking;

  const GameDetailDialog({
    super.key,
    required this.game,
    this.onNavigateToBooking,
  });

  /// Static helper to launch the dialog easily from any screen
  static Future<void> show(
    BuildContext context,
    GameItem game, {
    Function(int)? onNavigateToBooking,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => GameDetailDialog(
        game: game,
        onNavigateToBooking: onNavigateToBooking,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPopular = game.popularRank != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: GlassPanel(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          surfaceColor: AppTheme.surfaceDark.withValues(alpha: 0.95),
          borderColor: isPopular
              ? AppTheme.accentMagenta.withValues(alpha: 0.6)
              : AppTheme.accentCyan.withValues(alpha: 0.4),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cover Image Header ──
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildCoverImage(context),
                      ),
                    ),

                    // Top Gradient Overlay for smooth contrast
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              AppTheme.surfaceDark.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Top Badges
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Row(
                        children: [
                          if (isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: AppTheme.neonShadow(
                                  AppTheme.accentRed,
                                  blur: 8,
                                ),
                              ),
                              child: Text(
                                '#${game.popularRank} HOT GAME',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 9,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Close Button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Body Content ──
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        game.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Platform & Genre Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.accentCyan.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              game.platform,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentCyan,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.dividerColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              game.genre,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Quick Metadata Chips Grid ──
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetaInfoItem(
                              icon: Icons.people_outline,
                              label: 'Pemain',
                              value: game.effectivePlayerCount,
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: AppTheme.dividerColor,
                            ),
                            _buildMetaInfoItem(
                              icon: Icons.verified_user_outlined,
                              label: 'Rating',
                              value: game.effectiveRating,
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: AppTheme.dividerColor,
                            ),
                            _buildMetaInfoItem(
                              icon: Icons.business_outlined,
                              label: 'Developer',
                              value: game.effectivePublisher,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Description Section ──
                      Text(
                        'Deskripsi Game',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        game.effectiveDescription,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── CTA Action Buttons ──
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.dividerColor),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Tutup',
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: RetroButton(
                              label: 'BOOKING SEKARANG',
                              icon: Icons.play_arrow,
                              backgroundColor: AppTheme.accentMagenta,
                              isFullWidth: true,
                              onPressed: () {
                                Navigator.of(context).pop();
                                onNavigateToBooking?.call(3);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentCyan),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    final placeholderUrl =
        'https://placehold.co/600x337/1e1e2e/00d2ff/png?text=${Uri.encodeComponent(game.title)}';
    final fallbackWidget = Container(
      color: AppTheme.cardDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_esports,
              size: 48,
              color: AppTheme.accentCyan,
            ),
            const SizedBox(height: 8),
            Text(
              game.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );

    if (game.imageUrl != null) {
      if (game.imageUrl!.startsWith('http')) {
        return Image.network(
          game.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallbackWidget,
        );
      } else {
        return Image.asset(
          game.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallbackWidget,
        );
      }
    } else {
      return Image.network(
        placeholderUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallbackWidget,
      );
    }
  }
}
