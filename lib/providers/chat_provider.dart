import 'dart:convert';
import 'package:flutter/material.dart';
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

  List<ChatSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get currentSessionId => _currentSessionId;

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

    // Simulate AI delay
    await Future.delayed(const Duration(seconds: 2));

    // Simple AI dummy response
    final aiMsg = ChatMessage(
      id: DateTime.now().toString(),
      text: "Suis AI sedang memproses pesanmu: \"$text\". (Ini simulasi respons)",
      isUser: false,
      timestamp: DateTime.now(),
    );

    session.messages.add(aiMsg);
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
