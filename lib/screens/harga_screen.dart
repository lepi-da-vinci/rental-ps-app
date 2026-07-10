import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/retro_button.dart';

class HargaScreen extends StatelessWidget {
  final Function(int)? onNavigateToBooking;

  const HargaScreen({super.key, this.onNavigateToBooking});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Text(
              'PAKET SEWA',
              style: GoogleFonts.pressStart2p(
                fontSize: 16,
                color: AppTheme.accentCyan,
                shadows: AppTheme.neonShadow(AppTheme.accentCyan),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Harga sudah termasuk 2 controller & akses semua game.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Price cards
          ...dummyPricePackages.map((pkg) => _buildPriceCard(context, pkg)),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, dynamic pkg) {
    Color accentColor;
    IconData headerIcon;
    String? badge;

    if (pkg.tier == 'vip') {
      accentColor = AppTheme.accentMagenta;
      headerIcon = Icons.workspace_premium_outlined;
      badge = '👑';
    } else if (pkg.psType == 'PS5') {
      accentColor = AppTheme.accentMagenta;
      headerIcon = Icons.sports_esports;
      badge = '⭐';
    } else {
      accentColor = AppTheme.accentCyan;
      headerIcon = Icons.sports_esports;
      badge = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: pkg.isHighlighted
                ? accentColor
                : AppTheme.dividerColor,
            width: pkg.isHighlighted ? 2 : 1,
          ),
          boxShadow: pkg.isHighlighted ? AppTheme.neonShadow(accentColor, blur: 15) : null,
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(headerIcon, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        pkg.name.toUpperCase(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 10,
                          color: accentColor,
                          shadows: pkg.isHighlighted ? AppTheme.neonShadow(accentColor, blur: 2) : null,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Text(badge, style: const TextStyle(fontSize: 16)),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Price list
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                children: pkg.prices.map<Widget>((priceTier) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          priceTier.duration,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatRupiah(priceTier.price),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: pkg.isHighlighted ? accentColor : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1,
              color: AppTheme.dividerColor,
            ),

            // CTA button
            Padding(
              padding: const EdgeInsets.all(16),
              child: RetroButton(
                label: 'PESAN SEKARANG',
                icon: Icons.play_arrow,
                isFullWidth: true,
                backgroundColor: accentColor,
                onPressed: () => onNavigateToBooking?.call(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
