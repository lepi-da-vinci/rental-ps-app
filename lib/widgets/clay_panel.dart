import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A 3D Claymorphism container widget.
/// Creates an inflated 3D cushion effect with soft outer depth shadows and top highlight.
class ClayPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final List<BoxShadow>? customShadows;

  const ClayPanel({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.borderColor,
    this.width,
    this.height,
    this.alignment,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppTheme.surfaceDark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppTheme.dividerColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: customShadows ?? [
          // Bottom-Right Dark Extrusion Shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(4, 6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          // Top-Left Soft Ambient Light Highlight
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            offset: const Offset(-3, -3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
