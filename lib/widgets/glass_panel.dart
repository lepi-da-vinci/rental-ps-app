import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? borderColor;
  final Color? surfaceColor;
  final bool addHighlight;
  final bool enableBlur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.borderColor,
    this.surfaceColor,
    this.addHighlight = true,
    this.enableBlur = true,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = AppTheme.glassDecoration(
      borderColor: borderColor,
      borderRadius: borderRadius,
      surfaceColor: surfaceColor,
      addHighlight: addHighlight,
    );

    if (!enableBlur) {
      return Container(
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        alignment: alignment,
        clipBehavior: clipBehavior,
        decoration: decoration,
        child: child,
      );
    }

    // Outer container for shadow because ClipRRect clips the shadow of the inner container
    return Container(
      margin: margin,
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: clipBehavior != Clip.none ? clipBehavior : Clip.hardEdge,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: decoration.copyWith(boxShadow: []), // Remove shadow from inner container
            child: child,
          ),
        ),
      ),
    );
  }
}
