import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryService {
  static String get baseUrl => dotenv.env['API_URL'] ?? "";

  static Future<bool> syncHistoryToServer(
    List<Map<String, String>> blockedHistory,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Mengambil key yang sama dengan yang disimpan oleh HeartbeatService
      String? userId = prefs.getString('userId');
      String? guardianChatId = prefs.getString('guardianChatId');

      // Jika guardianChatId kosong, coba pulihkan dari server menggunakan userId
      if (userId != null &&
          (guardianChatId == null || guardianChatId.isEmpty)) {
        print(
          "Guardian ID tidak ditemukan di lokal, mencoba sinkronisasi dari server...",
        );
        guardianChatId = await _recoverGuardianId(userId);

        if (guardianChatId != null) {
          await prefs.setString('guardianChatId', guardianChatId);
        }
      }

      if (userId == null || blockedHistory.isEmpty) {
        print("Sync Batal: Data User ID atau Riwayat kosong.");
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/update-history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'guardianChatId':
              guardianChatId, // Sekarang ID Penjamin ikut terkirim
          'blockedHistory': blockedHistory,
        }),
      );

      if (response.statusCode == 200) {
        print("Sinkronisasi Berhasil ke document: $userId");
        return true;
      } else {
        print("Sinkronisasi Gagal: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error History Service: $e");
      return false;
    }
  }

  static Future<String?> _recoverGuardianId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user-status/$userId'),
      );
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
