import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    final accentColor = isDark ? AppTheme.neonGreen : AppTheme.darkGreen;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;

    return Drawer(
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Pixel art style: no rounded corners
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header / New Chat Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Provider.of<ChatProvider>(context, listen: false).createNewSession();
                  Navigator.pop(context); // Close drawer
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: accentColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black54 : Colors.grey.withValues(alpha: 0.3),
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      )
                    ]
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_box, color: accentColor),
                      const SizedBox(width: 12),
                      Text(
                        "Percakapan Baru",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Divider(height: 1, thickness: 1),
            
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                "Riwayat Sesi",
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // List of Sessions
            Expanded(
              child: ListView.builder(
                itemCount: chatProvider.sessions.length,
                itemBuilder: (context, index) {
                  final session = chatProvider.sessions[index];
                  final isSelected = session.id == chatProvider.currentSessionId;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    tileColor: isSelected ? (isDark ? AppTheme.darkCard : AppTheme.lightCard) : Colors.transparent,
                    leading: Icon(
                      Icons.chat_bubble_outline,
                      color: isSelected ? accentColor : (isDark ? Colors.grey[500] : Colors.grey[600]),
                    ),
                    title: Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? textColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: isDark ? Colors.red[300] : Colors.red,
                      onPressed: () {
                        Provider.of<ChatProvider>(context, listen: false).deleteSession(session.id);
                      },
                    ),
                    onTap: () {
                      Provider.of<ChatProvider>(context, listen: false).switchSession(session.id);
                      Navigator.pop(context); // Close drawer
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
