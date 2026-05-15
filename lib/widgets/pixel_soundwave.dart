import 'dart:math';
import 'package:flutter/material.dart';

class PixelSoundwave extends StatefulWidget {
  final Color color;
  final bool isListening;

  const PixelSoundwave({
    super.key,
    required this.color,
    required this.isListening,
  });

  @override
  State<PixelSoundwave> createState() => _PixelSoundwaveState();
}

class _PixelSoundwaveState extends State<PixelSoundwave> with TickerProviderStateMixin {
  final int _barCount = 7;
  late List<AnimationController> _controllers;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initControllers();
    if (widget.isListening) {
      _startAnimations();
    }
  }

  void _initControllers() {
    _controllers = List.generate(_barCount, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + _random.nextInt(300)),
      )..addListener(() {
          setState(() {});
        });
    });
  }

  void _startAnimations() {
    for (var controller in _controllers) {
      controller.duration = Duration(milliseconds: 300 + _random.nextInt(300));
      controller.repeat(reverse: true);
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.animateTo(0.1, duration: const Duration(milliseconds: 300)); // Reset to resting height
    }
  }

  @override
  void didUpdateWidget(PixelSoundwave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_barCount, (index) {
        // Use a base height of 10, max height of 80 when listening.
        // We use step-based heights to maintain the "pixel" feel.
        final value = _controllers[index].value;
        final rawHeight = widget.isListening ? 10.0 + (value * 70.0) : 10.0;
        
        // Quantize height to multiples of 4 for a pixel art blocky effect
        final pixelHeight = (rawHeight / 4).round() * 4.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12, // Blocky width
          height: pixelHeight,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.zero, // Sharp corners
          ),
        );
      }),
    );
  }
}
