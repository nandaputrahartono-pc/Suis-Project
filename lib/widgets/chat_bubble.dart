import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final bool isDarkMode;
  final bool animate; // Should we animate the text appearing?

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.isDarkMode,
    this.animate = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  String _displayedText = "";
  Timer? _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.animate && !widget.isUser) {
      _startTypingAnimation();
    } else {
      _displayedText = widget.text;
    }
  }

  void _startTypingAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _charIndex++;
          _displayedText = widget.text.substring(0, _charIndex);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      if (widget.animate && !widget.isUser) {
        _charIndex = 0;
        _displayedText = "";
        _startTypingAnimation();
      } else {
        _displayedText = widget.text;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = widget.isUser
        ? (widget.isDarkMode ? AppTheme.electricPurple : AppTheme.deepPurple)
        : (widget.isDarkMode ? AppTheme.darkCard : AppTheme.lightCard);

    final Color textColor = widget.isUser
        ? Colors.white
        : (widget.isDarkMode ? AppTheme.darkText : AppTheme.lightText);

    final Color borderColor = widget.isUser
        ? Colors.transparent
        : (widget.isDarkMode ? AppTheme.neonGreen : AppTheme.darkGreen);

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bubbleColor,
          // Pixel art style: blocky borders instead of rounded corners
          border: widget.isUser ? null : Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(0),
            topRight: const Radius.circular(0),
            bottomLeft: widget.isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomRight: widget.isUser ? const Radius.circular(16) : const Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isDarkMode ? Colors.black54 : Colors.grey.withValues(alpha: 0.3),
              offset: const Offset(4, 4), // Blocky shadow
              blurRadius: 0,
            )
          ]
        ),
        child: Text(
          _displayedText,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
