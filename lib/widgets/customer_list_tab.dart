import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/booking_provider.dart';
import '../data/dummy_data.dart';
import 'glass_panel.dart';

class CustomerListTab extends StatelessWidget {
  const CustomerListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final customers = provider.customers;
        
        if (customers.isEmpty) {
          return Center(
            child: Text(
              'Belum ada data pelanggan.',
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: customers.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final customer = customers[i];
            return GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar/Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.accentMagenta.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentMagenta.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        customer.name.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentMagenta,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                size: 12,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                customer.displayPhone,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.favorite,
                                size: 12,
                                color: AppTheme.accentRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                customer.favoriteConsole?.displayName ?? '-',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${customer.totalBookings}x Main',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah(customer.totalSpent),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          customer.lastVisit != null 
                            ? 'Terakhir: ${DateFormat('dd MMM').format(customer.lastVisit!)}'
                            : '-',
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
            );
          },
        );
      },
    );
  }
}
