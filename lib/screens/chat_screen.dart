import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppTheme.neonGreen : AppTheme.deepPurple,
                        width: 2,
                      ),
                      // Blocky UI
                      borderRadius: BorderRadius.zero, 
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: isDark ? AppTheme.darkText : AppTheme.lightText),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesanmu di sini...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _sendMessage(context),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.electricPurple : AppTheme.deepPurple,
                      border: Border.all(color: Colors.transparent),
                      boxShadow: [
                         BoxShadow(
                          color: isDark ? AppTheme.neonGreen : AppTheme.darkGreen,
                          offset: const Offset(4, 4), // Blocky button shadow
                          blurRadius: 0,
                        )
                      ]
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
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
