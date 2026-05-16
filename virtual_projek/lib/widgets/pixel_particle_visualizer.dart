import 'dart:math';
import 'package:flutter/material.dart';

class PixelParticle {
  double x;
  double y;
  double size;
  double speedY;
  double opacity;
  Color color;

  PixelParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.opacity,
    required this.color,
  });
}

class PixelParticleVisualizer extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const PixelParticleVisualizer({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<PixelParticleVisualizer> createState() => _PixelParticleVisualizerState();
}

class _PixelParticleVisualizerState extends State<PixelParticleVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<PixelParticle> _particles = [];
  final Random _random = Random();
  final int _particleCount = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        _updateParticles();
      })..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      _initParticles();
    }
  }

  void _initParticles() {
    final Size size = MediaQuery.of(context).size;
    _particles = List.generate(_particleCount, (index) {
      return _createParticle(size);
    });
  }

  PixelParticle _createParticle(Size size) {
    return PixelParticle(
      x: _random.nextDouble() * size.width,
      y: _random.nextDouble() * size.height,
      size: (_random.nextInt(3) + 1) * 4.0, // Multiples of 4 for blocky look (4, 8, 12)
      speedY: (_random.nextDouble() * 2) + 0.5,
      opacity: _random.nextDouble(),
      color: _random.nextBool() ? widget.primaryColor : widget.secondaryColor,
    );
  }

  void _updateParticles() {
    final Size size = MediaQuery.of(context).size;
    for (var particle in _particles) {
      particle.y -= particle.speedY; // Move upwards
      
      // Pulse opacity
      particle.opacity += (_random.nextBool() ? 0.05 : -0.05);
      particle.opacity = particle.opacity.clamp(0.1, 1.0);

      // Reset if off screen
      if (particle.y < -particle.size) {
        particle.y = size.height + particle.size;
        particle.x = _random.nextDouble() * size.width;
      }
    }
    setState(() {}); // Trigger repaint
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _PixelPainter(_particles),
    );
  }
}

class _PixelPainter extends CustomPainter {
  final List<PixelParticle> particles;

  _PixelPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      // Draw squares to mimic pixels
      canvas.drawRect(
        Rect.fromLTWH(particle.x, particle.y, particle.size, particle.size),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPainter oldDelegate) => true;
}
