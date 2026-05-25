import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../services/backend_config.dart';

/// Widget yang menampilkan avatar VRM 3D via WebView.
/// 
/// Berkomunikasi dengan Three.js melalui evaluateJavascript:
/// - [startLipSync] → mulut avatar bergerak
/// - [stopLipSync] → mulut avatar tutup
/// - [setExpression] → ubah ekspresi (happy, sad, neutral, dll)
class VrmAvatar extends StatefulWidget {
  final bool isSpeakingWord;     // For lip sync
  final bool isSpeakingSentence; // For body animation
  final bool isListening;
  final bool isProcessing;
  final String animationContext; // 'idle', 'greeting', 'normal'

  const VrmAvatar({
    super.key,
    this.isSpeakingWord = false,
    this.isSpeakingSentence = false,
    this.isListening = false,
    this.isProcessing = false,
    this.animationContext = 'idle',
  });

  @override
  State<VrmAvatar> createState() => VrmAvatarState();
}

class VrmAvatarState extends State<VrmAvatar> {
  InAppWebViewController? _webViewController;
  bool _isReady = false;

  @override
  void didUpdateWidget(VrmAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // React to lip sync state changes (word level)
    if (widget.isSpeakingWord != oldWidget.isSpeakingWord) {
      if (widget.isSpeakingWord) {
        startLipSync();
      } else {
        stopLipSync();
      }
    }
    // React to body animation state changes (sentence level)
    if (widget.isSpeakingSentence != oldWidget.isSpeakingSentence) {
      setSpeakingSentence(widget.isSpeakingSentence);
    }
    // React to listening state changes
    if (widget.isListening != oldWidget.isListening) {
      setListening(widget.isListening);
    }
    // React to processing/thinking state changes
    if (widget.isProcessing != oldWidget.isProcessing) {
      setProcessing(widget.isProcessing);
    }
    // React to animation context changes
    if (widget.animationContext != oldWidget.animationContext) {
      setAnimationContext(widget.animationContext);
    }
  }

  void setAnimationContext(String type) {
    if (_isReady && _webViewController != null) {
      _webViewController!.evaluateJavascript(
          source: 'window.playVrmaContext("$type")');
    }
  }

  void setSpeakingSentence(bool speaking) {
    if (_isReady && _webViewController != null) {
      _webViewController!.evaluateJavascript(
          source: 'window.setSpeakingSentence($speaking)');
    }
  }

  void setListening(bool listening) {
    if (_isReady && _webViewController != null) {
      _webViewController!.evaluateJavascript(
          source: 'window.setListening($listening)');
    }
  }

  void setProcessing(bool processing) {
    if (_isReady && _webViewController != null) {
      _webViewController!.evaluateJavascript(
          source: 'window.setProcessing($processing)');
    }
  }

  void startLipSync() {
    if (_isReady && _webViewController != null) {
      _webViewController!.evaluateJavascript(source: 'window.startSpeaking()');
    }
  }

  void stopLipSync() {
    if (_isReady && _webViewController != null) {
      _webViewController!.evaluateJavascript(source: 'window.stopSpeaking()');
    }
  }

  void setExpression(String name) {
    if (_isReady && _webViewController != null) {
      _webViewController!.evaluateJavascript(source: 'window.setExpression("$name")');
    }
  }

  @override
  Widget build(BuildContext context) {
    final backendConfig = Provider.of<BackendConfig>(context, listen: false);

    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        transparentBackground: true,
        javaScriptEnabled: true,
        allowFileAccess: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
        mediaPlaybackRequiresUserGesture: false,
        disableVerticalScroll: true,
        disableHorizontalScroll: true,
        supportZoom: false,
        cacheEnabled: true,
      ),
      onWebViewCreated: (controller) async {
        _webViewController = controller;

        // Load HTML from assets
        final htmlContent = await rootBundle.loadString('assets/vrm_viewer.html');
        await controller.loadData(
          data: htmlContent,
          mimeType: 'text/html',
          encoding: 'utf-8',
          baseUrl: WebUri('http://localhost'),
        );
      },
      onLoadStop: (controller, url) async {
        // Initialize avatar dengan backend URL
        final backendUrl = backendConfig.baseUrl;
        await controller.evaluateJavascript(
          source: 'window.initAvatar("$backendUrl")',
        );
        setState(() => _isReady = true);

        // Apply current states
        if (widget.isSpeakingWord) startLipSync();
        if (widget.isSpeakingSentence) setSpeakingSentence(true);
        if (widget.isListening) setListening(true);
        if (widget.isProcessing) setProcessing(true);
        setAnimationContext(widget.animationContext);
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('VRM WebView: ${consoleMessage.message}');
      },
    );
  }
}
