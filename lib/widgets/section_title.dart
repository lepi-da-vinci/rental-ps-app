import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Section heading — clean, no glow.
class SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.color = AppTheme.textPrimary,
    this.fontSize = 15,
    this.padding = const EdgeInsets.only(bottom: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.pressStart2p(
          fontSize: 12,
          color: AppTheme.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}
