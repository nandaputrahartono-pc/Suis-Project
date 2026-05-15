import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pixel_particle_visualizer.dart';
import '../widgets/pixel_soundwave.dart';

class VirtualAssistantScreen extends StatefulWidget {
  const VirtualAssistantScreen({super.key});

  @override
  State<VirtualAssistantScreen> createState() => _VirtualAssistantScreenState();
}

class _VirtualAssistantScreenState extends State<VirtualAssistantScreen> {
  bool _isListening = false;

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });
  }

  void _endCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
        // Hide default back button because we have an "End Call" button now
        automaticallyImplyLeading: false, 
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Visualizer (Ambient particles)
          if (_isListening)
            PixelParticleVisualizer(
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          
          // Center Content: Soundwave and Status
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pixel Soundwave replaces the giant center button
                        PixelSoundwave(
                          color: _isListening ? secondaryColor : primaryColor,
                          isListening: _isListening,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _isListening ? "Mendengarkan..." : "Disenyapkan",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
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
                      // Mic Toggle Button
                      GestureDetector(
                        onTap: _toggleListening,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                            border: Border.all(
                              color: _isListening ? secondaryColor : primaryColor,
                              width: 3,
                            ),
                            // Blocky corners for pixel look
                            borderRadius: BorderRadius.zero,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black54 : Colors.grey.withValues(alpha: 0.5),
                                offset: const Offset(6, 6),
                                blurRadius: 0, // Sharp shadow
                              )
                            ]
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_off,
                            size: 40,
                            color: _isListening ? secondaryColor : primaryColor,
                          ),
                        ),
                      ),
                      
                      // End Call Button (Red X)
                      GestureDetector(
                        onTap: _endCall,
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
                            ]
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
