import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/chatbot_model.dart';

class ChatController extends ChangeNotifier {
  final String? _apiKey = dotenv.env['GEMINI_API_KEY'];
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  List<ChatMessage> messages = [];
  bool isTyping = false;
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();

  ChatController() {
    _loadHistoryAndInit();
  }

  Future<void> _loadHistoryAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedChats = prefs.getStringList('chat_history');

    if (savedChats != null && savedChats.isNotEmpty) {
      messages = savedChats.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      messages = [
        ChatMessage(
          text:
              "Halo 👋 saya Garda AI! Saya bantu kamu menjaga diri dari paparan situs dan aplikasi judi. Ada yang ingin kamu tanyakan?",
          isBot: true,
        ),
      ];
    }
    notifyListeners();

    _initGemini();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _initGemini() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey!,
      systemInstruction: Content.text(
        "Kamu adalah Garda AI, seorang asisten psikologi digital yang empatik, sabar, dan profesional. "
        "Tugas utamamu adalah membantu pengguna yang kecanduan judi online (judol). "
        "Berikan dukungan emosional, tips praktis berhenti berjudi, dan edukasi tentang bahaya judi. "
        "Gunakan bahasa Indonesia yang santai, suportif, namun tetap solutif. "
        "Jangan menghakimi pengguna.",
      ),
    );

    final history =
        messages.map((m) {
          return Content(m.isBot ? 'model' : 'user', [TextPart(m.text)]);
        }).toList();

    _chatSession = _model.startChat(history: history);
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add(ChatMessage(text: text, isBot: false));
    _saveMessages();

    textController.clear();
    isTyping = true;
    notifyListeners();
    _scrollToBottom();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final botReply =
          response.text ?? "Maaf, saya sedang mengalami gangguan jaringan.";

      messages.add(ChatMessage(text: botReply, isBot: true));
      _saveMessages();
    } catch (e) {
      messages.add(
        ChatMessage(text: "Terjadi kesalahan koneksi: $e", isBot: true),
      );
    } finally {
      isTyping = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = messages.map((e) => e.toJson()).toList();
    await prefs.setStringList('chat_history', jsonList);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    textController.dispose();
    super.dispose();
  }
}
