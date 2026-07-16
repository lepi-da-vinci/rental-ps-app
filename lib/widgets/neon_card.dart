import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// A card widget updated to "Liquid Glass" theme with background blur and specular highlights.
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
    this.borderColor = AppTheme.glassBorder,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: padding,
            decoration: AppTheme.glassDecoration(
              borderColor: hasGlow ? (glowColor ?? borderColor) : borderColor,
              borderRadius: borderRadius,
              addHighlight: true,
            ).copyWith(
              boxShadow: hasGlow ? AppTheme.neonShadow(glowColor ?? borderColor, spread: 2, blur: 20) : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
