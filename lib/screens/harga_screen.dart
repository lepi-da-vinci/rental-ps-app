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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'HARGA',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Paket ',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Bermain',
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
            'Transparan, tanpa biaya tersembunyi. Pilih durasi yang paling cocok buat kamu.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Promo Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentCyan.withValues(alpha: 0.1), AppTheme.accentMagenta.withValues(alpha: 0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department, color: AppTheme.accentCyan, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROMO WEEKEND!',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentCyan,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Main 5 jam bayar 4 jam khusus Sabtu-Minggu.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Price cards
          LayoutBuilder(
            builder: (context, constraints) {
              bool isLarge = constraints.maxWidth > 800;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: dummyPricePackages.map((pkg) {
                  return SizedBox(
                    width: isLarge ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                    child: _buildPriceCard(context, pkg),
                  );
                }).toList(),
              );
            },
          ),
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
