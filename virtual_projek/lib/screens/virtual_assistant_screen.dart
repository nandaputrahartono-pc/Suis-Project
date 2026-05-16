import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/va_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pixel_particle_visualizer.dart';
import '../widgets/pixel_soundwave.dart';

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
    // Dipanggil saat screen kehilangan fokus (swipe back, pop, dsb)
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
      appBar: AppBar(
        title: const Text('Suis AI Live'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background particles
          if (vaProvider.isActive)
            PixelParticleVisualizer(
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Soundwave — fixed height
                          SizedBox(
                            height: 80,
                            child: Center(
                              child: PixelSoundwave(
                                color: secondaryColor,
                                isAnimating: vaProvider.isSpeakingWord,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Status text atau Loading animation
                          if (vaProvider.isProcessing)
                            _ThinkingIndicator(color: secondaryColor)
                          else
                            Text(
                              vaProvider.statusText,
                              style: GoogleFonts.vt323(
                                fontSize: 20,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 24),

                          // Subtitle
                          SizedBox(
                            height: 120,
                            child: vaProvider.subtitle.isNotEmpty
                                ? SingleChildScrollView(
                                    reverse: true,
                                    child: Text(
                                      vaProvider.subtitle,
                                      style: GoogleFonts.vt323(
                                        fontSize: 22,
                                        color: vaProvider.isUserTurn
                                            ? secondaryColor
                                            : textColor,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Control Bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        backgroundColor.withValues(alpha: 0.0),
                        backgroundColor.withValues(alpha: 0.8),
                        backgroundColor,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mic Button
                      GestureDetector(
                        onTap: () {
                          if (!vaProvider.isSessionActive) {
                            vaProvider.startSession();
                          } else {
                            vaProvider.toggleMute();
                          }
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: vaProvider.isListening
                                ? (isDark ? AppTheme.neonGreen : AppTheme.darkGreen)
                                : (isDark ? AppTheme.darkCard : AppTheme.lightCard),
                            border: Border.all(
                              color: vaProvider.isProcessing
                                  ? Colors.grey
                                  : vaProvider.isMuted
                                      ? Colors.red
                                      : (vaProvider.isListening ? secondaryColor : primaryColor),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.zero,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black54 : Colors.grey.withValues(alpha: 0.5),
                                offset: const Offset(6, 6),
                                blurRadius: 0,
                              )
                            ],
                          ),
                          child: vaProvider.isProcessing
                              ? Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple,
                                  ),
                                )
                              : Icon(
                                  vaProvider.isMuted
                                      ? Icons.mic_off
                                      : Icons.mic,
                                  size: 40,
                                  color: vaProvider.isListening
                                      ? (isDark ? AppTheme.darkBackground : Colors.white)
                                      : vaProvider.isMuted
                                          ? Colors.red
                                          : primaryColor,
                                ),
                        ),
                      ),

                      // End Call Button
                      GestureDetector(
                        onTap: () {
                          vaProvider.stopSession();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.red[900] : Colors.red[700],
                            border: Border.all(
                              color: isDark ? Colors.redAccent : Colors.red,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.zero,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black54 : Colors.grey.withValues(alpha: 0.5),
                                offset: const Offset(6, 6),
                                blurRadius: 0,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated thinking indicator — 3 titik berkedip bergantian (pixel-art style).
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
                fontSize: 20,
                color: widget.color.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 4),
            // 3 titik pixel berkedip bergantian
            ...List.generate(3, (i) {
              // Tiap titik muncul di phase berbeda
              final phase = (_controller.value * 3 - i).clamp(0.0, 1.0);
              final opacity = phase < 0.5 ? phase * 2 : (1.0 - phase) * 2;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                color: widget.color.withValues(alpha: opacity.clamp(0.15, 1.0)),
              );
            }),
          ],
        );
      },
    );
  }
}
