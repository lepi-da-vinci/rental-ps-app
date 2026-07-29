import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';

/// A beautifully designed digital receipt widget.
class ReceiptDialog extends StatelessWidget {
  final Booking booking;

  const ReceiptDialog({super.key, required this.booking});

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  int _calculateTotal() {
    // Quick calculation based on dummy prices
    // In a real app, this should come from the backend or a price provider
    int pricePerHour = 0;
    switch (booking.psType) {
      case ConsoleType.ps4:
        pricePerHour = 10000;
        break;
      case ConsoleType.ps5:
      case ConsoleType.ps5Vip:
      case ConsoleType.nintendoVip:
        pricePerHour = 15000;
        break;
    }
    return pricePerHour * booking.durationHours;
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final isLunas = booking.paymentStatus == PaymentStatus.lunas;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Container(
          width: 360,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB), // Paper white
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videogame_asset,
                            color: AppTheme.accentCyan, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'TIMELESS PS',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jl. Letkol Pol. Surya Dharma No. 51',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabelValue('No. Resi', booking.id),
                        _buildLabelValue(
                          'Tanggal',
                          DateFormat('dd MMM yyyy').format(booking.date),
                          alignRight: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabelValue('Pelanggan', booking.customerName),
                        _buildLabelValue('Kasir', 'Admin', alignRight: true),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    const _DashedDivider(),
                    const SizedBox(height: 20),

                    // Item
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.assignedUnit,
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${booking.time} - ${booking.endTime}',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${booking.durationHours} Jam',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatCurrency(total),
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    const _DashedDivider(),
                    const SizedBox(height: 20),

                    // Total & Payment
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _formatCurrency(total),
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.accentCyan, // Highlight total
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLunas
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLunas
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Metode Bayar',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                booking.paymentMethod.displayName.toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isLunas ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isLunas ? 'LUNAS' : 'BELUM LUNAS',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer Bar (Actions)
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: AppTheme.textMuted,
                        ),
                        child: Text(
                          'Tutup',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.dividerColor,
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // Simple share action hint since we don't have share_plus yet
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Silakan Screenshot layar ini untuk membagikan struk.',
                                style: GoogleFonts.spaceGrotesk(),
                              ),
                              backgroundColor: AppTheme.accentCyan,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share, size: 18),
                        label: Text(
                          'Bagikan',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: AppTheme.accentCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.black54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
              ),
            );
          }),
        );
      },
    );
  }
}
