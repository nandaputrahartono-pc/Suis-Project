import 'dart:math';
import 'package:flutter/material.dart';

/// Pixel Soundwave — always visible, animates based on intensity.
/// 
/// [isAnimating] = true → bars bergerak naik turun (AI bicara)
/// [isAnimating] = false → bars datar/rendah (idle)
/// Widget SELALU ditampilkan, tidak pernah di-unmount.
class PixelSoundwave extends StatefulWidget {
  final Color color;
  final bool isAnimating; // true saat AI sedang mengucapkan kata

  const PixelSoundwave({
    super.key,
    required this.color,
    this.isAnimating = false,
  });

  @override
  State<PixelSoundwave> createState() => _PixelSoundwaveState();
}

class _PixelSoundwaveState extends State<PixelSoundwave> with SingleTickerProviderStateMixin {
  final int _barCount = 7;
  late AnimationController _master;
  late List<double> _phases;
  final Random _random = Random();

  // Smooth intensity transition
  double _currentIntensity = 0.0;
  static const double _intensitySpeed = 0.08; // Kecepatan transisi

  @override
  void initState() {
    super.initState();
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(_onTick)
     ..repeat();

    _phases = List.generate(_barCount, (_) => _random.nextDouble() * 2 * pi);
  }

  void _onTick() {
    // Smooth lerp intensity
    final target = widget.isAnimating ? 1.0 : 0.0;
    if ((_currentIntensity - target).abs() > 0.01) {
      _currentIntensity += (target - _currentIntensity) * _intensitySpeed;
      _currentIntensity = _currentIntensity.clamp(0.0, 1.0);
    } else {
      _currentIntensity = target;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _master.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_barCount, (index) {
        // Sine wave per bar
        final wave = sin((_master.value * 2 * pi) + _phases[index]);
        final normalized = (wave + 1) / 2; // 0.0 - 1.0

        // Base height: 12px (flat). Animated height: up to 80px.
        // _currentIntensity controls how much animation affects the height
        final animatedHeight = normalized * 68.0 * _currentIntensity;
        final rawHeight = 12.0 + animatedHeight;

        // Quantize ke kelipatan 4 untuk efek pixel
        final pixelHeight = (rawHeight / 4).round() * 4.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: pixelHeight,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.zero,
          ),
        );
      }),
    );
  }
}
