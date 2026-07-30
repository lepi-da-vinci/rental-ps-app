import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A 3D Claymorphism Tactile Button that visually depresses when pressed.
class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool isPrimary;
  final IconData? icon;

  const ClayButton({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.textColor,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.width,
    this.height,
    this.isPrimary = true,
    this.icon,
  });

  factory ClayButton.text({
    required String text,
    VoidCallback? onTap,
    Color? color,
    Color? textColor,
    IconData? icon,
    bool isPrimary = true,
    double borderRadius = 18,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    double? width,
    double? height,
  }) {
    return ClayButton(
      onTap: onTap,
      color: color,
      textColor: textColor,
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
            Icon(icon, size: 20, color: textColor ?? (isPrimary ? Colors.white : AppTheme.textPrimary)),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: textColor ?? (isPrimary ? Colors.white : AppTheme.textPrimary),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? (widget.isPrimary ? AppTheme.clayCyan : AppTheme.claySurface);
    final isDisabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isPressed ? 3.0 : 0.0, 0),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: isDisabled ? bgColor.withValues(alpha: 0.4) : bgColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.isPrimary 
                ? Colors.white.withValues(alpha: 0.3)
                : AppTheme.clayCyan.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: _isPressed || isDisabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(1, 2),
                    blurRadius: 4,
                  )
                ]
              : [
                  BoxShadow(
                    color: widget.isPrimary 
                        ? AppTheme.clayCyan.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(3, 5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}
