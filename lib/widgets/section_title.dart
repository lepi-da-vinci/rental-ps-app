import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color color;
  final EdgeInsetsGeometry padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.color = AppTheme.textPrimary,
    this.padding = const EdgeInsets.only(bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: color,
                    height: 1.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
