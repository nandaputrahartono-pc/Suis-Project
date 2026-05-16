import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/pixel_typing_indicator.dart';
import 'virtual_assistant_screen.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context) {
    if (_controller.text.trim().isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final messages = chatProvider.currentMessages;

    return Scaffold(
      drawer: const ChatDrawer(),
      appBar: AppBar(
        title: const Text('Suis AI'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.graphic_eq),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VirtualAssistantScreen()),
              );
            },
            tooltip: 'Virtual Assistant',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length + (chatProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  // Pixel Typing Loading Indicator
                  return PixelTypingIndicator(isDarkMode: isDark);
                }
                final message = messages[index];
                
                // Only animate the very last AI message if it's fresh (less than 3 seconds old)
                final bool isFresh = DateTime.now().difference(message.timestamp).inSeconds < 3;
                final bool shouldAnimate = !message.isUser && (index == messages.length - 1) && isFresh;

                return ChatBubble(
                  text: message.text,
                  isUser: message.isUser,
                  isDarkMode: isDark,
                  animate: shouldAnimate,
                );
              },
            ),
          ),
          // Input Area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  border: Border.all(
                    color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.zero,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black54 : Colors.grey.withValues(alpha: 0.3),
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    )
                  ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text Field
                    TextField(
                      controller: _controller,
                      style: TextStyle(color: isDark ? AppTheme.darkText : AppTheme.lightText),
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesanmu di sini...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tools and Send Button Row
                    Row(
                      children: [
                        // Attach Button (+)
                        InkWell(
                          onTap: () {}, // Future feature
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple, width: 2),
                            ),
                            child: Icon(Icons.add, size: 24, color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple),
                          ),
                        ),
                        const Spacer(),
                        // Model Selector
                        InkWell(
                          onTap: () => _showModelSelectorBottomSheet(context, chatProvider, isDark),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple, width: 2),
                              color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  chatProvider.selectedModel,
                                  style: GoogleFonts.vt323(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down, color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Send Button
                        GestureDetector(
                          onTap: () => _sendMessage(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.electricPurple : AppTheme.deepPurple,
                              border: Border.all(
                                color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.send, 
                              color: Colors.white,
                              size: 20,
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
        ],
      ),
    );
  }

  void _showModelSelectorBottomSheet(BuildContext context, ChatProvider chatProvider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple, width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  "Pilih Model Suis AI",
                  style: GoogleFonts.vt323(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildModelOption(context, chatProvider, isDark, 'Queen', 'Menjawab dengan cepat dan lugas.'),
              _buildModelOption(context, chatProvider, isDark, 'GPT', 'Kemampuan penalaran dan koding tingkat lanjut.'),
              _buildModelOption(context, chatProvider, isDark, 'Claude', 'Ahli dalam merangkai kata dan menulis panjang.'),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Widget _buildModelOption(BuildContext context, ChatProvider chatProvider, bool isDark, String modelName, String description) {
    final bool isSelected = chatProvider.selectedModel == modelName;
    return InkWell(
      onTap: () {
        chatProvider.setModel(modelName);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: isSelected 
            ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
            : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modelName,
                    style: GoogleFonts.vt323(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.vt323(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple),
          ],
        ),
      ),
    );
  }
}
