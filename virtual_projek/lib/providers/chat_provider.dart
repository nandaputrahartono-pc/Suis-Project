import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      text: map['text'],
      isUser: map['isUser'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class ChatSession {
  final String id;
  String title;
  List<ChatMessage> messages;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'],
      title: map['title'],
      messages: (map['messages'] as List<dynamic>).map((m) => ChatMessage.fromMap(m)).toList(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class ChatProvider with ChangeNotifier {
  List<ChatSession> _sessions = [];
  String? _currentSessionId;
  final String _storageKey = 'chat_sessions_v2'; // Changed key to avoid collision with v1
  bool _isLoading = false;
  String _selectedModel = 'Queen';

  // Backend URL — ganti sesuai environment
  // Untuk Android Emulator: http://10.0.2.2:3000
  // Untuk iOS Simulator / Desktop / Web: http://localhost:3000
  // Untuk device fisik: http://<IP_KOMPUTER>:3000
  static const String _backendUrl = 'http://10.0.2.2:3000';

  List<ChatSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get currentSessionId => _currentSessionId;
  String get selectedModel => _selectedModel;

  void setModel(String model) {
    if (_selectedModel != model) {
      _selectedModel = model;
      notifyListeners();
    }
  }

  ChatSession? get currentSession {
    try {
      return _sessions.firstWhere((s) => s.id == _currentSessionId);
    } catch (e) {
      return null;
    }
  }

  List<ChatMessage> get currentMessages => currentSession?.messages ?? [];

  ChatProvider() {
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? sessionsJson = prefs.getString(_storageKey);
    
    if (sessionsJson != null) {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      _sessions = decoded.map((item) => ChatSession.fromMap(item)).toList();
      // Sort by descending created date
      _sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      if (_sessions.isNotEmpty) {
        _currentSessionId = _sessions.first.id;
      }
    } else {
      // Create first default session
      createNewSession();
    }
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_sessions.map((s) => s.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void createNewSession() {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "Percakapan Baru",
      messages: [
        ChatMessage(
          id: DateTime.now().toString(),
          text: "Halo! Aku Suis AI. Ada yang bisa kubantu di sesi baru ini?",
          isUser: false,
          timestamp: DateTime.now(),
        )
      ],
      createdAt: DateTime.now(),
    );
    
    _sessions.insert(0, newSession);
    _currentSessionId = newSession.id;
    _saveSessions();
    notifyListeners();
  }

  void switchSession(String sessionId) {
    if (_currentSessionId != sessionId) {
      _currentSessionId = sessionId;
      notifyListeners();
    }
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_sessions.isEmpty) {
      final newSession = ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Percakapan Baru",
        messages: [
          ChatMessage(
            id: DateTime.now().toString(),
            text: "Halo! Aku Suis AI. Ada yang bisa kubantu di sesi baru ini?",
            isUser: false,
            timestamp: DateTime.now(),
          )
        ],
        createdAt: DateTime.now(),
      );
      _sessions.insert(0, newSession);
      _currentSessionId = newSession.id;
    } else if (_currentSessionId == sessionId) {
      _currentSessionId = _sessions.first.id;
    }
    _saveSessions();
    notifyListeners();
  }

  /// Konversi chat history ke format yang dibutuhkan Groq API.
  /// Hanya kirim pesan user dan assistant (skip system/welcome message pertama).
  List<Map<String, String>> _buildApiMessages(List<ChatMessage> messages) {
    final apiMessages = <Map<String, String>>[];
    for (final msg in messages) {
      // Skip welcome message (pesan pertama dari AI saat sesi baru)
      if (!msg.isUser && apiMessages.isEmpty && messages.indexOf(msg) == 0) {
        continue;
      }
      apiMessages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }
    return apiMessages;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _currentSessionId == null) return;

    final session = currentSession!;

    // Auto update title if it's the first user message
    if (session.messages.length == 1 && session.title == "Percakapan Baru") {
       // take first 20 chars max for title
      session.title = text.length > 20 ? "${text.substring(0, 20)}..." : text;
    }

    // Add user message
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    session.messages.add(userMsg);
    _isLoading = true;
    notifyListeners();
    _saveSessions();

    try {
      // Kirim chat history ke backend Fastify
      final apiMessages = _buildApiMessages(session.messages);
      
      final response = await http.post(
        Uri.parse('$_backendUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': apiMessages,
          'model': _selectedModel,
        }),
      ).timeout(const Duration(seconds: 30));

      String aiText;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        aiText = data['response'] ?? 'Maaf, aku nggak bisa merespon saat ini.';
      } else if (response.statusCode == 429) {
        aiText = '⚠️ Wah, aku lagi capek nih. Coba lagi beberapa detik ya!';
      } else {
        final data = jsonDecode(response.body);
        aiText = '⚠️ ${data['message'] ?? 'Terjadi kesalahan di server.'}';
      }

      final aiMsg = ChatMessage(
        id: DateTime.now().toString(),
        text: aiText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      session.messages.add(aiMsg);

    } catch (e) {
      // Network error / timeout / backend mati
      final errorMsg = ChatMessage(
        id: DateTime.now().toString(),
        text: '⚠️ Gagal terhubung ke server Suis AI. Pastikan backend sudah berjalan.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      session.messages.add(errorMsg);
    }

    _isLoading = false;
    notifyListeners();
    _saveSessions();
  }
  
  Future<void> clearHistory() async {
    if (_currentSessionId == null) return;
    final session = currentSession!;
    session.messages.clear();
    session.messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          text: "Riwayat sesi ini telah dihapus. Halo! Aku Suis AI.",
          isUser: false,
          timestamp: DateTime.now(),
        )
      );
    _saveSessions();
    notifyListeners();
  }
}
