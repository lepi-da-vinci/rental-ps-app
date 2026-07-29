import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../theme/app_theme.dart';
import '../providers/booking_provider.dart';
import '../models/enums.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int _touchedIndex = -1;

  Future<void> _exportCSV(Map<String, int> revenueByDate, Map<String, int> countByDate) async {
    try {
      final downloadPath = '${Platform.environment['USERPROFILE']}\\Downloads\\Laporan_Pendapatan.csv';
      final file = File(downloadPath);
      String csvData = 'Tanggal,Total Sesi,Pendapatan (Rp)\n';
      
      final sortedDates = revenueByDate.keys.toList()..sort();
      for (final date in sortedDates) {
        csvData += '$date,${countByDate[date]},${revenueByDate[date]}\n';
      }
      
      await file.writeAsString(csvData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV berhasil disimpan di folder Downloads'), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export CSV: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  Future<void> _exportPDF(Map<String, int> revenueByDate, Map<String, int> countByDate) async {
    try {
      final pdf = pw.Document();
      final sortedDates = revenueByDate.keys.toList()..sort((a, b) => b.compareTo(a)); // Newest first
      
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Laporan Pendapatan Harian - Timeless PS', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  context: context,
                  data: <List<String>>[
                    <String>['Tanggal', 'Total Sesi', 'Pendapatan (Rp)'],
                    ...sortedDates.map((date) => [
                      date,
                      countByDate[date].toString(),
                      currencyFormat.format(revenueByDate[date]).replaceAll('Rp', '').trim(),
                    ]),
                  ],
                ),
              ],
            );
          },
        ),
      );
      
      final downloadPath = '${Platform.environment['USERPROFILE']}\\Downloads\\Laporan_Pendapatan.pdf';
      final file = File(downloadPath);
      await file.writeAsBytes(await pdf.save());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF berhasil disimpan di folder Downloads'), backgroundColor: AppTheme.accentGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export PDF: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final bookings = provider.bookings;

    // Aggregate data: Group by Date
    final Map<String, int> revenueByDate = {};
    final Map<String, int> countByDate = {};
    
    // Group by PS type for pie chart
    final Map<String, int> countByConsole = {'PS4': 0, 'PS5': 0, 'VIP': 0};
    
    // Group by Date for expandable details
    final Map<String, Map<String, int>> consoleCountByDate = {};

    for (final b in bookings) {
      if (b.paymentStatus == PaymentStatus.lunas) {
        final dateStr = '${b.date.year}-${b.date.month.toString().padLeft(2, '0')}-${b.date.day.toString().padLeft(2, '0')}';
        
        // Calculate price based on duration and ps_type
        int pricePerHour = 10000;
        final typeName = b.psType.name.toLowerCase();
        if (typeName.contains('ps5')) pricePerHour = 15000;
        if (typeName.contains('vip')) pricePerHour = 20000;
        
        final revenue = b.durationHours * pricePerHour;

        revenueByDate[dateStr] = (revenueByDate[dateStr] ?? 0) + revenue;
        countByDate[dateStr] = (countByDate[dateStr] ?? 0) + 1;
        
        consoleCountByDate[dateStr] ??= {'PS4': 0, 'PS5': 0, 'VIP': 0};

        if (typeName.contains('vip')) {
          countByConsole['VIP'] = (countByConsole['VIP'] ?? 0) + 1;
          consoleCountByDate[dateStr]!['VIP'] = consoleCountByDate[dateStr]!['VIP']! + 1;
        } else if (typeName.contains('ps5')) {
          countByConsole['PS5'] = (countByConsole['PS5'] ?? 0) + 1;
          consoleCountByDate[dateStr]!['PS5'] = consoleCountByDate[dateStr]!['PS5']! + 1;
        } else {
          countByConsole['PS4'] = (countByConsole['PS4'] ?? 0) + 1;
          consoleCountByDate[dateStr]!['PS4'] = consoleCountByDate[dateStr]!['PS4']! + 1;
        }
      }
    }

    // Sort dates
    final sortedDates = revenueByDate.keys.toList()..sort();
    // Keep last 7 days for the chart
    final chartDates = sortedDates.length > 7 ? sortedDates.sublist(sortedDates.length - 7) : sortedDates;

    double maxRevenue = 0;
    for (final date in chartDates) {
      if (revenueByDate[date]! > maxRevenue) maxRevenue = revenueByDate[date]!.toDouble();
    }
    
    // Round max to nearest 100k
    maxRevenue = ((maxRevenue / 100000).ceil() * 100000).toDouble();
    if (maxRevenue == 0) maxRevenue = 100000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Laporan Pendapatan',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'csv') {
                    _exportCSV(revenueByDate, countByDate);
                  } else if (value == 'pdf') {
                    _exportPDF(revenueByDate, countByDate);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'csv',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, size: 20),
                        SizedBox(width: 8),
                        Text('Export CSV'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 20),
                        SizedBox(width: 8),
                        Text('Export PDF'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.download, size: 18, color: AppTheme.surfaceDark),
                      const SizedBox(width: 8),
                      Text('Export', style: GoogleFonts.spaceGrotesk(color: AppTheme.surfaceDark, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // GRAPH CHART SECTION (GRAFIK DI ATAS)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grafik Pendapatan (7 Hari Terakhir)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: chartDates.isEmpty
                      ? const Center(child: Text('Belum ada data pendapatan'))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxRevenue,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => AppTheme.surfaceDark,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    currencyFormat.format(rod.toY),
                                    GoogleFonts.spaceGrotesk(
                                      color: AppTheme.accentCyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              touchCallback: (FlTouchEvent event, barTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      barTouchResponse == null ||
                                      barTouchResponse.spot == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                                });
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 && value.toInt() < chartDates.length) {
                                      final date = chartDates[value.toInt()];
                                      final dayStr = date.substring(8, 10);
                                      final monthStr = date.substring(5, 7);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '$dayStr/$monthStr',
                                          style: TextStyle(
                                            color: value.toInt() == _touchedIndex 
                                                ? AppTheme.accentCyan 
                                                : AppTheme.textMuted,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const SizedBox.shrink();
                                    return Text(
                                      '${(value / 1000).toInt()}k',
                                      style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: maxRevenue / 4,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppTheme.dividerColor.withValues(alpha: 0.5),
                                strokeWidth: 1,
                                dashArray: [5, 5],
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(chartDates.length, (index) {
                              final date = chartDates[index];
                              final revenue = revenueByDate[date]!.toDouble();
                              final isTouched = index == _touchedIndex;
                              
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: revenue,
                                    color: isTouched ? AppTheme.accentCyan : AppTheme.accentCyan.withValues(alpha: 0.7),
                                    width: 22,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: maxRevenue,
                                      color: AppTheme.surfaceDark.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // DATA TABEL SECTION (DATA DI BAWAH GRAFIK)
          Text(
            'Rincian Pendapatan Harian',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          sortedDates.isEmpty
            ? const Text('Belum ada data', style: TextStyle(color: AppTheme.textMuted))
            : Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedDates.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: AppTheme.dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    // Reverse to show latest on top
                    final date = sortedDates[sortedDates.length - 1 - index];
                    final revenue = revenueByDate[date]!;
                    final count = countByDate[date]!;
                    
                    final consoleStats = consoleCountByDate[date]!;
                    
                    return Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: AppTheme.accentCyan,
                        collapsedIconColor: AppTheme.textMuted,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.attach_money, color: AppTheme.accentGreen, size: 20),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              currencyFormat.format(revenue),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '$count Sesi (Lunas)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        children: [
                          Container(
                            color: AppTheme.surfaceDark.withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            child: Column(
                              children: [
                                _buildDetailRow('PS4', consoleStats['PS4']!, AppTheme.bookingColors[0]),
                                const SizedBox(height: 8),
                                _buildDetailRow('PS5', consoleStats['PS5']!, AppTheme.bookingColors[1]),
                                const SizedBox(height: 8),
                                _buildDetailRow('VIP (PS5/Nintendo)', consoleStats['VIP']!, AppTheme.bookingColors[2]),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
        Text('$count sesi', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
