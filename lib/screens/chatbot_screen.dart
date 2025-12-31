import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/chatbot_controller.dart';

class GardaChatScreen extends StatefulWidget {
  const GardaChatScreen({super.key});

  @override
  State<GardaChatScreen> createState() => _GardaChatScreenState();
}

class _GardaChatScreenState extends State<GardaChatScreen> {
  final ChatController _controller = ChatController();
  final String robotAssetPath = 'assets/images/robot.png';
  
  // Theme Colors
  final Color primaryDark = const Color(0xFF138066);
  final Color primaryLight = const Color(0xFF00E5C5);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Note: We avoid top Safe area padding here because GuardianHomeScreen handles it via IndexedStack/SafeArea
    // or we can keep it flexible.
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(), // Custom Header
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                if (_controller.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  controller: _controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _controller.messages.length + (_controller.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _controller.messages.length && _controller.isTyping) {
                      return _buildTypingIndicator();
                    }
                    final msg = _controller.messages[index];
                    return ChatBubble(
                      message: msg.text,
                      isBot: msg.isBot,
                      robotIconPath: robotAssetPath,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              robotAssetPath,
              width: 30,
              height: 30,
              errorBuilder: (_, __, ___) => Icon(Icons.smart_toy, color: primaryDark, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "GardaBot",
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Asisten Psikologi Virtual",
                style: GoogleFonts.leagueSpartan(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
            ),
            child: Image.asset(robotAssetPath, width: 80, height: 80, errorBuilder: (_,__,___) => Icon(Icons.smart_toy, size: 80, color: Colors.grey[300])),
          ),
          const SizedBox(height: 20),
          Text(
            "Halo! Saya GardaBot.",
            style: GoogleFonts.leagueSpartan(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            "Ceritakan masalahmu, saya siap mendengarkan.",
            style: GoogleFonts.leagueSpartan(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16), // Symmetrical padding
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Light grey bg for input
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller.textController,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.leagueSpartan(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Ketik pesan...",
                  hintStyle: GoogleFonts.leagueSpartan(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _controller.sendMessage(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryDark,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: primaryDark.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Row(
              children: [
                _dot(Colors.grey[400]!),
                const SizedBox(width: 4),
                _dot(Colors.grey[400]!),
                const SizedBox(width: 4),
                _dot(Colors.grey[400]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isBot;
  final String robotIconPath;
  // Colors 
  final Color primaryDark = const Color(0xFF138066);

  const ChatBubble({super.key, required this.message, required this.isBot, required this.robotIconPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              backgroundImage: AssetImage(robotIconPath),
              onBackgroundImageError: (_, __) {},
              child: Image.asset(robotIconPath, errorBuilder: (_,__,___) => Icon(Icons.smart_toy, size: 20, color: primaryDark)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : primaryDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomRight: Radius.circular(isBot ? 20 : 4),
                  bottomLeft: Radius.circular(isBot ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: message,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.leagueSpartan(
                    color: isBot ? Colors.black87 : Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
