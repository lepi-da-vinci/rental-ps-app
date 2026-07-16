import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A button updated to "Liquid Glass" theme with frosted glass effect
/// and a pulsating neon glow.
class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;
  final Color? backgroundColor;

  const RetroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = false,
    this.backgroundColor,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 8.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      HapticFeedback.lightImpact();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppTheme.accentCyan;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.2), // Translucent color
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5],
                ),
                boxShadow: AppTheme.neonShadow(
                  bgColor, 
                  spread: 2, 
                  blur: _glowAnimation.value,
                ),
              ),
              child: ElevatedButton(
                onPressed: _handleTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white, // White text for contrast on glass
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: Colors.white),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
