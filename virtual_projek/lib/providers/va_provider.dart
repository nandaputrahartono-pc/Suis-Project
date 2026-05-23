import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../services/backend_config.dart';

/// Data timing setiap kata dari Edge TTS.
class WordTiming {
  final int offsetMs;
  final int durationMs;
  final String text;

  WordTiming({required this.offsetMs, required this.durationMs, required this.text});

  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      offsetMs: json['offset'] as int,
      durationMs: json['duration'] as int,
      text: json['text'] as String,
    );
  }
}

/// Provider untuk Virtual Assistant — continuous voice conversation.
class VaProvider with ChangeNotifier {
  final BackendConfig _backendConfig;
  String get _backendUrl => _backendConfig.baseUrl;

  // Speech-to-Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // State
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;       // AI audio sedang playing
  bool _isSpeakingWord = false;    // AI sedang mengucapkan kata (untuk soundwave rhythm)
  bool _isSessionActive = false;
  bool _isMuted = false;           // User mute mic
  String _statusText = 'Tekan mic untuk mulai';
  
  // Subtitle — plain text, tidak di-clear sampai percakapan baru
  String _subtitle = '';
  bool _isUserTurn = true;
  String _fullAiResponse = '';

  // Word timing
  List<WordTiming> _wordTimings = [];
  final List<Timer> _activeTimers = [];

  // Conversation history
  final List<Map<String, String>> _conversationHistory = [];
  String _lastRecognizedText = '';

  // Cooldown — prevent rapid restart cycles
  bool _isRestarting = false;

  // Getters
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  bool get isSpeaking => _isSpeaking;
  bool get isSpeakingWord => _isSpeakingWord;
  bool get isSessionActive => _isSessionActive;
  bool get isMuted => _isMuted;
  String get statusText => _statusText;
  String get subtitle => _subtitle;
  bool get isUserTurn => _isUserTurn;
  bool get isActive => _isListening || _isProcessing || _isSpeaking;

  VaProvider(this._backendConfig) {
    _initSpeech();
    _initAudioPlayer();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        if (_isSessionActive && !_isSpeaking && !_isProcessing && !_isMuted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_isSessionActive && !_isSpeaking && !_isMuted) {
              _startListening();
            }
          });
        }
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' && _isSessionActive && !_isSpeaking && !_isProcessing) {
          _isListening = false;
          notifyListeners();
          
          if (_lastRecognizedText.trim().isNotEmpty) {
            _onUserFinishedSpeaking(_lastRecognizedText.trim());
          } else if (!_isMuted) {
            _restartListeningWithCooldown();
          }
        }
      },
    );
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((_) {
      _isSpeaking = false;
      _isSpeakingWord = false;
      _cancelTimers();

      // Subtitle TETAP tampil — tidak di-clear
      // Pastikan full response ditampilkan
      _subtitle = _fullAiResponse;
      _statusText = _isMuted ? 'Mic dimatikan' : 'Mendengarkan...';
      notifyListeners();

      // Auto-restart listening jika tidak muted
      if (_isSessionActive && !_isMuted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (_isSessionActive && !_isMuted) {
            _isUserTurn = true;
            notifyListeners();
            _startListening();
          }
        });
      }
    });
  }

  // ============ PUBLIC API ============

  /// Start session — tekan mic pertama kali.
  Future<void> startSession() async {
    if (!_speechAvailable) {
      _statusText = 'Speech recognition tidak tersedia';
      notifyListeners();
      return;
    }

    _isSessionActive = true;
    _isMuted = false;
    _subtitle = '';
    _isUserTurn = true;
    _statusText = 'Mendengarkan...';
    notifyListeners();

    _startListening();
  }

  /// Toggle mute mic.
  void toggleMute() {
    if (!_isSessionActive) return;
    
    _isMuted = !_isMuted;

    if (_isMuted) {
      // Mute: stop listening
      _speech.stop();
      _isListening = false;
      _statusText = 'Mic dimatikan';
    } else {
      // Unmute: start listening (kecuali AI sedang bicara)
      if (!_isSpeaking && !_isProcessing) {
        _statusText = 'Mendengarkan...';
        _startListening();
      }
    }
    notifyListeners();
  }

  /// Stop session — end call.
  void stopSession() {
    if (!_isSessionActive) return; // Already stopped
    _isSessionActive = false;
    _speech.stop();
    _audioPlayer.stop();
    _cancelTimers();
    _conversationHistory.clear();
    _isListening = false;
    _isProcessing = false;
    _isSpeaking = false;
    _isSpeakingWord = false;
    _isMuted = false;
    _isRestarting = false;
    _subtitle = '';
    _fullAiResponse = '';
    _isUserTurn = true;
    _statusText = 'Tekan mic untuk mulai';
    _wordTimings = [];
    _lastRecognizedText = '';
    notifyListeners();
  }

  // ============ INTERNAL ============

  Future<void> _startListening() async {
    if (!_speechAvailable || !_isSessionActive || _isSpeaking || _isMuted) return;

    _isListening = true;
    _lastRecognizedText = '';
    notifyListeners();

    try {
      await _speech.listen(
        onResult: (result) {
          _lastRecognizedText = result.recognizedWords;
          
          if (_lastRecognizedText.isNotEmpty) {
            _subtitle = _lastRecognizedText;
            _isUserTurn = true;
            notifyListeners();
          }
        },
        localeId: 'id_ID',
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } catch (e) {
      debugPrint('Listen error: $e');
      _isListening = false;
      _restartListeningWithCooldown();
    }
  }

  /// Restart listening dengan cooldown 1.5 detik untuk mencegah mati-nyala berulang.
  void _restartListeningWithCooldown() {
    if (_isRestarting || !_isSessionActive || _isSpeaking || _isMuted) return;
    _isRestarting = true;

    Future.delayed(const Duration(milliseconds: 1500), () {
      _isRestarting = false;
      if (_isSessionActive && !_isSpeaking && !_isMuted && !_isProcessing) {
        _startListening();
      }
    });
  }

  void _onUserFinishedSpeaking(String text) {
    _isListening = false;
    _sendToAI(text);
  }

  Future<void> _sendToAI(String text) async {
    _isProcessing = true;
    _isUserTurn = false;
    _statusText = 'Sedang berpikir...';
    notifyListeners();

    _conversationHistory.add({'role': 'user', 'content': text});

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': _conversationHistory,
          'model': 'Queen',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _fullAiResponse = data['response'] ?? 'Maaf, aku nggak bisa merespon.';
      } else {
        _fullAiResponse = 'Ada kesalahan di server.';
      }

      _conversationHistory.add({'role': 'assistant', 'content': _fullAiResponse});
      _isProcessing = false;
      notifyListeners();

      await _speakResponse(_fullAiResponse);

    } catch (e) {
      _fullAiResponse = 'Gagal terhubung ke server.';
      _isProcessing = false;
      _subtitle = _fullAiResponse;
      _statusText = _isMuted ? 'Mic dimatikan' : 'Mendengarkan...';
      _isUserTurn = false;
      notifyListeners();

      if (_isSessionActive && !_isMuted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (_isSessionActive && !_isMuted) {
            _isUserTurn = true;
            _startListening();
          }
        });
      }
    }
  }

  Future<void> _speakResponse(String text) async {
    _statusText = 'Suis AI menjawab';
    _isSpeaking = true;
    _isSpeakingWord = false;
    _subtitle = '';
    _isUserTurn = false;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/api/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Parse word boundaries
        final wbHeader = response.headers['x-word-boundaries'];
        if (wbHeader != null) {
          final List<dynamic> wbJson = jsonDecode(wbHeader);
          _wordTimings = wbJson.map((e) => WordTiming.fromJson(e)).toList();
        } else {
          _wordTimings = [];
        }

        // Simpan audio
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/suis_tts.mp3');
        await audioFile.writeAsBytes(response.bodyBytes);

        // Start word-level rhythm tracking + subtitle sync
        _startWordRhythm();

        // Play audio
        await _audioPlayer.play(DeviceFileSource(audioFile.path));

      } else {
        _subtitle = text;
        _isSpeaking = false;
        _statusText = _isMuted ? 'Mic dimatikan' : 'Mendengarkan...';
        notifyListeners();
        if (_isSessionActive && !_isMuted) _startListening();
      }
    } catch (e) {
      debugPrint('TTS error: $e');
      _subtitle = text;
      _isSpeaking = false;
      _statusText = 'Suara gagal dimuat';
      notifyListeners();
      if (_isSessionActive && !_isMuted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (_isSessionActive && !_isMuted) _startListening();
        });
      }
    }
  }

  /// Word-level rhythm: soundwave naik saat kata diucapkan, turun di antara kata.
  /// Juga update subtitle kata per kata.
  void _startWordRhythm() {
    _cancelTimers();
    _subtitle = '';
    _isSpeakingWord = false;

    if (_wordTimings.isEmpty) {
      _subtitle = _fullAiResponse;
      _isSpeakingWord = true;
      notifyListeners();
      return;
    }

    for (int i = 0; i < _wordTimings.length; i++) {
      final timing = _wordTimings[i];
      
      // Saat kata mulai diucapkan → soundwave NAIK + update subtitle
      final startTimer = Timer(Duration(milliseconds: timing.offsetMs), () {
        _isSpeakingWord = true;
        // Subtitle kumulatif
        _subtitle = _wordTimings
            .sublist(0, i + 1)
            .map((w) => w.text)
            .join(' ');
        notifyListeners();
      });
      _activeTimers.add(startTimer);

      // Saat kata selesai diucapkan → soundwave TURUN (brief pause)
      final endTimer = Timer(
        Duration(milliseconds: timing.offsetMs + timing.durationMs),
        () {
          _isSpeakingWord = false;
          notifyListeners();
        },
      );
      _activeTimers.add(endTimer);
    }
  }

  void _cancelTimers() {
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
  }

  @override
  void dispose() {
    _speech.stop();
    _audioPlayer.dispose();
    _cancelTimers();
    super.dispose();
  }
}
