import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/booking_provider.dart';
import '../data/dummy_data.dart';
import 'glass_panel.dart';

class CustomerListTab extends StatefulWidget {
  const CustomerListTab({super.key});

  @override
  State<CustomerListTab> createState() => _CustomerListTabState();
}

class _CustomerListTabState extends State<CustomerListTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final allCustomers = provider.customers;
        final filteredCustomers = allCustomers.where((c) {
          final query = _searchQuery.toLowerCase().trim();
          if (query.isEmpty) return true;
          return c.name.toLowerCase().contains(query) || c.phone.contains(query);
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Summary ──
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.people_alt_rounded,
                              color: AppTheme.accentCyan,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL PELANGGAN',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textMuted,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${allCustomers.length} Gamer',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Search Bar ──
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau nomor telepon pelanggan...',
                  hintStyle: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.accentCyan),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Customer Cards List ──
              if (filteredCustomers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Belum ada data pelanggan.'
                        : 'Tidak ada pelanggan yang cocok dengan pencarian.',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCustomers.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 14),
                  itemBuilder: (ctx, i) {
                    final customer = filteredCustomers[i];
                    return GlassPanel(
                      borderRadius: 16,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            // Avatar/Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.accentMagenta.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.accentMagenta.withValues(alpha: 0.3),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name.substring(0, 1).toUpperCase()
                                    : '?',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 13,
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
                                        size: 13,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentCyan.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${customer.totalBookings}x Main',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentCyan,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah(customer.totalSpent),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentGreen,
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                ),
            ],
          ),
        );
      },
    );
  }
}
