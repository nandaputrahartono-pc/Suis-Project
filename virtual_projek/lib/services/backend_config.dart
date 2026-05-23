import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;

/// Konfigurasi backend dengan auto-discovery.
/// 
/// Saat app dibuka, otomatis scan jaringan lokal untuk mencari
/// backend Suis AI (endpoint /api/health di port 3000).
/// IP yang ditemukan disimpan di SharedPreferences sebagai cache.
class BackendConfig with ChangeNotifier {
  static const String _key = 'backend_ip';
  static const String _defaultIp = '192.168.1.21';
  static const int _port = 3000;

  String _ip = _defaultIp;
  bool _isLoaded = false;
  bool _isDiscovering = false;
  String _status = 'Menghubungkan...';

  String get ip => _ip;
  int get port => _port;
  String get baseUrl => 'http://$_ip:$_port';
  bool get isLoaded => _isLoaded;
  bool get isDiscovering => _isDiscovering;
  String get status => _status;

  BackendConfig() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Load cached IP dulu supaya app bisa langsung jalan
    final prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString(_key) ?? _defaultIp;
    _isLoaded = true;
    notifyListeners();

    // Lalu auto-discover di background
    await autoDiscover();
  }

  /// Auto-discover backend di jaringan lokal.
  /// Scan subnet yang sama dengan HP untuk mencari /api/health.
  Future<void> autoDiscover() async {
    _isDiscovering = true;
    _status = 'Mencari server...';
    notifyListeners();

    try {
      // 1. Cek IP yang sudah tersimpan dulu (paling cepat)
      if (await _checkServer(_ip)) {
        _status = 'Terhubung';
        _isDiscovering = false;
        notifyListeners();
        return;
      }

      // 2. Ambil IP WiFi HP
      final networkInfo = NetworkInfo();
      final wifiIp = await networkInfo.getWifiIP();
      debugPrint('WiFi IP: $wifiIp');

      if (wifiIp == null || wifiIp.isEmpty) {
        _status = 'WiFi tidak terdeteksi';
        _isDiscovering = false;
        notifyListeners();
        return;
      }

      // 3. Extract subnet (misal: 192.168.1)
      final parts = wifiIp.split('.');
      if (parts.length != 4) {
        _status = 'Format IP tidak valid';
        _isDiscovering = false;
        notifyListeners();
        return;
      }
      final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';

      // 4. Scan subnet secara paralel (1-254)
      _status = 'Scanning $subnet.x ...';
      notifyListeners();

      final foundIp = await _scanSubnet(subnet);

      if (foundIp != null) {
        _ip = foundIp;
        _status = 'Terhubung';
        // Simpan IP yang ditemukan
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, _ip);
      } else {
        _status = 'Server tidak ditemukan';
      }
    } catch (e) {
      debugPrint('Auto-discover error: $e');
      _status = 'Gagal scan jaringan';
    }

    _isDiscovering = false;
    notifyListeners();
  }

  /// Scan seluruh subnet secara paralel, return IP yang merespon.
  Future<String?> _scanSubnet(String subnet) async {
    // Fire 254 requests paralel dengan timeout pendek
    final futures = <Future<String?>>[];

    for (int i = 1; i <= 254; i++) {
      final testIp = '$subnet.$i';
      futures.add(_checkServerReturn(testIp));
    }

    // Tunggu semua selesai, ambil yang pertama berhasil
    final results = await Future.wait(futures);
    for (final result in results) {
      if (result != null) return result;
    }
    return null;
  }

  /// Cek apakah server backend ada di IP ini.
  Future<bool> _checkServer(String testIp) async {
    try {
      final response = await http.get(
        Uri.parse('http://$testIp:$_port/api/health'),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200 && response.body.contains('Suis AI')) {
        return true;
      }
    } catch (_) {
      // Timeout atau connection refused — IP ini bukan server
    }
    return false;
  }

  /// Cek server dan return IP jika berhasil, null jika tidak.
  Future<String?> _checkServerReturn(String testIp) async {
    final success = await _checkServer(testIp);
    return success ? testIp : null;
  }

  /// Manual set IP (fallback jika auto-discover gagal).
  Future<void> setIp(String newIp) async {
    if (newIp.trim().isEmpty) return;
    _ip = newIp.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _ip);
    _status = 'Terhubung (manual)';
    notifyListeners();
  }
}
