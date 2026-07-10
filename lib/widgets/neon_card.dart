import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A clean card widget with subtle border — no glow, professional look.
class NeonCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hasGlow;
  final Color? glowColor;

  const NeonCard({
    super.key,
    required this.child,
    this.borderColor = AppTheme.dividerColor,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: padding,
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: hasGlow ? AppTheme.neonShadow(glowColor ?? borderColor, spread: 1, blur: 12) : null,
        ),
        child: child,
      ),
    );
  }
}
