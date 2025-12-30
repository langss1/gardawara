import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HeartbeatService {
  static String get baseUrl => dotenv.env['API_URL'] ?? "";

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static Future<bool> verifyGuard(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/verify-guard/$chatId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      print("Error Verify: $e");
      return false;
    }
  }

  static Future<bool> startProtection(
    String uid,
    String chatId,
    String name,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('userId', uid);
      await prefs.setString('guardianChatId', chatId);
      await prefs.setString('userName', name);
      await prefs.setBool('isProtected', true);

      await _sendHeartbeatToServer(uid, chatId, name);

      await Workmanager().registerPeriodicTask(
        "unique-heartbeat-id",
        "judiGuardHeartbeat",
        frequency: const Duration(minutes: 30),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );

      return true;
    } catch (e) {
      print("Error startProtection: $e");
      return false;
    }
  }

  static Future<void> _sendHeartbeatToServer(
    String uid,
    String chatId,
    String name,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/heartbeat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": uid,
          "guardianChatId": chatId,
          "userName": name,
        }),
      );
      print("Respon Awal Server: ${response.statusCode}");
    } catch (e) {
      print("Gagal kirim awal: $e");
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // PENTING: Isolate background perlu memuat ulang .env
    await dotenv.load(fileName: ".env");
    final String backgroundBaseUrl = dotenv.env['API_URL'] ?? "";

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final guardianChatId = prefs.getString('guardianChatId');
    final userName = prefs.getString('userName');

    if (userId == null || backgroundBaseUrl.isEmpty) return Future.value(false);

    try {
      final response = await http.post(
        Uri.parse("$backgroundBaseUrl/heartbeat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "guardianChatId": guardianChatId,
          "userName": userName,
        }),
      );
      print("Background Task Success: ${response.statusCode}");
      return Future.value(true);
    } catch (e) {
      print("Error Background: $e");
      return Future.value(false);
    }
  });
}
