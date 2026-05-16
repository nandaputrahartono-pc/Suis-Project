import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PixelTypingIndicator extends StatefulWidget {
  final bool isDarkMode;

  const PixelTypingIndicator({super.key, required this.isDarkMode});

  @override
  State<PixelTypingIndicator> createState() => _PixelTypingIndicatorState();
}

class _PixelTypingIndicatorState extends State<PixelTypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = widget.isDarkMode ? AppTheme.neonGreen : AppTheme.darkGreen;
    final Color textColor = widget.isDarkMode ? AppTheme.darkText : AppTheme.lightText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Calculate dot count for "..." (0, 1, 2, 3)
          final int dotCount = (_controller.value * 4).floor();
          final String dots = "." * dotCount;

          // Rotation for the loading square (spins in 4 discrete steps to look pixelated/choppy)
          final int rotationStep = (_controller.value * 8).floor();
          final double rotation = rotationStep * (pi / 4); // 45 degree steps

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinning Pixel Square (Thinking animation)
              Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: accentColor, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text with animated dots
              Text(
                "Suis AI sedang berpikir$dots",
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
