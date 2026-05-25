import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/va_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pixel_soundwave.dart';
import '../widgets/vrm_avatar.dart';

class VirtualAssistantScreen extends StatefulWidget {
  const VirtualAssistantScreen({super.key});

  @override
  State<VirtualAssistantScreen> createState() => _VirtualAssistantScreenState();
}

class _VirtualAssistantScreenState extends State<VirtualAssistantScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    final vaProvider = Provider.of<VaProvider>(context, listen: false);
    vaProvider.stopSession();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vaProvider = Provider.of<VaProvider>(context, listen: false);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      vaProvider.stopSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final vaProvider = Provider.of<VaProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final Color primaryColor = isDark ? AppTheme.electricPurple : AppTheme.deepPurple;
    final Color secondaryColor = isDark ? AppTheme.neonGreen : AppTheme.darkGreen;
    final Color textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final Color backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Layer 1: 3D Avatar — FULLSCREEN
          Positioned.fill(
            child: VrmAvatar(
              isSpeakingWord: vaProvider.isSpeakingWord,
              isSpeakingSentence: vaProvider.isSpeaking,
              isListening: vaProvider.isListening && !vaProvider.isSpeaking,
              isProcessing: vaProvider.isProcessing,
              animationContext: vaProvider.animationContext,
            ),
          ),

          // Layer 2: Top gradient + back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor.withValues(alpha: 0.7),
                    backgroundColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Suis AI Live',
                        style: GoogleFonts.vt323(
                          fontSize: 22,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Layer 3: Bottom UI overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor.withValues(alpha: 0.0),
                    backgroundColor.withValues(alpha: 0.6),
                    backgroundColor.withValues(alpha: 0.9),
                    backgroundColor,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Removed soundwave

                      // Status / Thinking
                      if (vaProvider.isProcessing)
                        _ThinkingIndicator(color: secondaryColor)
                      else
                        Text(
                          vaProvider.statusText,
                          style: GoogleFonts.vt323(
                            fontSize: 18,
                            color: textColor.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 8),

                      // Subtitle
                      SizedBox(
                        height: 60,
                        child: vaProvider.subtitle.isNotEmpty
                            ? SingleChildScrollView(
                                reverse: true,
                                child: Text(
                                  vaProvider.subtitle,
                                  style: GoogleFonts.vt323(
                                    fontSize: 18,
                                    color: vaProvider.isUserTurn
                                        ? secondaryColor
                                        : textColor,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),

                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Mic
                          GestureDetector(
                            onTap: () {
                              if (!vaProvider.isSessionActive) {
                                vaProvider.startSession();
                              } else {
                                vaProvider.toggleMute();
                              }
                            },
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: vaProvider.isListening
                                    ? secondaryColor.withValues(alpha: 0.9)
                                    : (isDark ? AppTheme.darkCard : AppTheme.lightCard).withValues(alpha: 0.8),
                                border: Border.all(
                                  color: vaProvider.isProcessing
                                      ? Colors.grey
                                      : vaProvider.isMuted
                                          ? Colors.red
                                          : (vaProvider.isListening ? secondaryColor : primaryColor),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.zero,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black38,
                                    offset: const Offset(3, 3),
                                    blurRadius: 0,
                                  )
                                ],
                              ),
                              child: vaProvider.isProcessing
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: secondaryColor,
                                      ),
                                    )
                                  : Icon(
                                      vaProvider.isMuted ? Icons.mic_off : Icons.mic,
                                      size: 28,
                                      color: vaProvider.isListening
                                          ? (isDark ? AppTheme.darkBackground : Colors.white)
                                          : vaProvider.isMuted
                                              ? Colors.red
                                              : primaryColor,
                                    ),
                            ),
                          ),

                          // End Call
                          GestureDetector(
                            onTap: () {
                              vaProvider.stopSession();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.red[800]?.withValues(alpha: 0.9),
                                border: Border.all(
                                  color: Colors.redAccent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.zero,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    offset: Offset(3, 3),
                                    blurRadius: 0,
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated thinking indicator
class _ThinkingIndicator extends StatefulWidget {
  final Color color;
  const _ThinkingIndicator({required this.color});

  @override
  State<_ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<_ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sedang berpikir',
              style: GoogleFonts.vt323(
                fontSize: 18,
                color: widget.color.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 4),
            ...List.generate(3, (i) {
              final phase = (_controller.value * 3 - i).clamp(0.0, 1.0);
              final opacity = phase < 0.5 ? phase * 2 : (1.0 - phase) * 2;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                color: widget.color.withValues(alpha: opacity.clamp(0.15, 1.0)),
              );
            }),
          ],
        );
      },
    );
  }
}
