import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String backendUrl = "https://api-judi-guard.onrender.com/heartbeat";
const String taskName = "judiGuardHeartbeat";

class HeartbeatService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  static Future<void> startProtection(
    String uid,
    String chatId,
    String name,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', uid);
    await prefs.setString('guardianChatId', chatId);
    await prefs.setString('userName', name);
    await prefs.setBool('isProtected', true);

    await _sendHeartbeatToServer(uid, chatId, name);

    await Workmanager().registerPeriodicTask(
      "unique-heartbeat-id",
      taskName,
      frequency: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> _sendHeartbeatToServer(
    String uid,
    String chatId,
    String name,
  ) async {
    try {
      print("Mengirim data awal ke server...");
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          // Butuh dart:convert
          "userId": uid,
          "guardianChatId": chatId,
          "userName": name,
        }),
      );
      print("Respon Server: ${response.statusCode}");
    } catch (e) {
      print("Gagal kirim awal: $e");
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final guardianChatId = prefs.getString('guardianChatId');
    final userName = prefs.getString('userName');

    if (userId == null) return Future.value(false);

    try {
      print("Background: Mengirim sinyal kehidupan: $userName");

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "guardianChatId": guardianChatId,
          "userName": userName,
        }),
      );

      print(response.statusCode == 200 ? "Sukses" : "Gagal: ${response.body}");
    } catch (e) {
      print("Error Background: $e");
    }

    return Future.value(true);
  });
}
