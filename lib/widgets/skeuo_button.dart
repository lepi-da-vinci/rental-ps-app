import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A DualSense PS5 Controller Tactile 3D Skeuomorphic Button.
class SkeuoButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? ledGlowColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool isPrimary;
  final IconData? icon;

  const SkeuoButton({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.ledGlowColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.width,
    this.height,
    this.isPrimary = true,
    this.icon,
  });

  factory SkeuoButton.text({
    required String text,
    VoidCallback? onTap,
    Color? color,
    Color? textColor,
    Color? ledGlowColor,
    IconData? icon,
    bool isPrimary = true,
    double borderRadius = 16,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    double? width,
    double? height,
  }) {
    return SkeuoButton(
      onTap: onTap,
      color: color,
      ledGlowColor: ledGlowColor,
      borderRadius: borderRadius,
      padding: padding,
      width: width,
      height: height,
      isPrimary: isPrimary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: textColor ?? (isPrimary ? Colors.white : AppTheme.accentCyan),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor ?? (isPrimary ? Colors.white : AppTheme.textPrimary),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<SkeuoButton> createState() => _SkeuoButtonState();
}

class _SkeuoButtonState extends State<SkeuoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? (widget.isPrimary ? AppTheme.ps5LedBlue : AppTheme.ps5MetallicSlate);
    final glowColor = widget.ledGlowColor ?? AppTheme.ps5LedBlue;
    final isDisabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isPressed ? 2.5 : 0.0, 0),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: isDisabled ? bgColor.withValues(alpha: 0.35) : bgColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isPressed
                ? [
                    bgColor.withValues(alpha: 0.8),
                    bgColor,
                  ]
                : [
                    Colors.white.withValues(alpha: widget.isPrimary ? 0.25 : 0.1),
                    bgColor,
                    Colors.black.withValues(alpha: 0.3),
                  ],
            stops: const [0.0, 0.4, 1.0],
          ),
          border: Border.all(
            color: widget.isPrimary
                ? Colors.white.withValues(alpha: 0.4)
                : AppTheme.ps5LedBlue.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: _isPressed || isDisabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(1, 2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  // Outer LED RGB Light Glow
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  // Bottom Physical Bevel Shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    offset: const Offset(3, 5),
                    blurRadius: 8,
                  ),
                  // Top Metallic Specular Highlight
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.2),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}
