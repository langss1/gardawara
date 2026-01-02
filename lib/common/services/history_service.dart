import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryService {
  static String get baseUrl => dotenv.env['API_URL'] ?? "";

  static DateTime? _lastSyncTime;

  static const _syncInterval = Duration(seconds: 15);

  static Future<bool> syncHistoryToServer(
    List<Map<String, String>> blockedHistory,
  ) async {
    final now = DateTime.now();
    if (_lastSyncTime != null &&
        now.difference(_lastSyncTime!) < _syncInterval) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      String? userId = prefs.getString('userId');
      String? guardianChatId = prefs.getString('guardianChatId');

      if (userId == null || blockedHistory.isEmpty) {
        return false;
      }

      if (guardianChatId == null || guardianChatId.isEmpty) {
        print("🛡️ History: Guardian ID kosong, mencoba recover...");
        guardianChatId = await _recoverGuardianId(userId);

        if (guardianChatId != null) {
          await prefs.setString('guardianChatId', guardianChatId);
        }
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/update-history'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'guardianChatId': guardianChatId,
              'blockedHistory': blockedHistory,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _lastSyncTime = DateTime.now();
        print("✅ Sinkronisasi Berhasil (Throttled): $userId");
        return true;
      } else {
        print("⚠️ Sinkronisasi Gagal: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error History Service: $e");
      return false;
    }
  }

  static Future<String?> _recoverGuardianId(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/user-status/$userId'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['guardianChatId']?.toString();
      }
    } catch (e) {
      print("Gagal recover ID: $e");
    }
    return null;
  }
}
