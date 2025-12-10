import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Halo 👋 saya Garda AI! Saya bantu kamu menjaga diri dari paparan situs dan aplikasi judi. Ada yang ingin kamu tanyakan?'
    },
  ];

  // Keywords to detect (Same as in Kotlin for Android App)
  final List<String> _blacklist = ["judi", "slot gacor", "toto", "situs gacor", "bandar judi", "taruhan bola", "judi online"];

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();

    // --- ALGORITHM DETECTION SIMULATION ---
    // Defines the logic that runs natively on Android Accessibility Service
    bool isRestricted = _blacklist.any((word) => text.toLowerCase().contains(word));
    
    if (isRestricted) {
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (ctx) => AlertDialog(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
           title: const Row(
             children: [
               Icon(Icons.gpp_bad_rounded, color: Colors.red, size: 32),
               SizedBox(width: 12),
               Text("TERDETEKSI!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
             ],
           ),
           content: const Text(
             "Sistem GardaWara mendeteksi kata kunci terkait perjudian. \n\n"
             "Akses ini otomatis diblokir untuk melindungi Anda.",
             style: TextStyle(fontSize: 16, height: 1.5),
           ),
           actions: [
             Container(
               width: double.infinity,
               margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.red,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 onPressed: () {
                   Navigator.pop(ctx); // Close Dialog
                   Navigator.pop(context); // Force User Back (Simulate Blocking)
                 },
                 child: const Text("KEMBALI KE AMAN", style: TextStyle(fontWeight: FontWeight.bold)),
               ),
             )
           ],
         )
       );
       return; // Stop processing the message
    }

    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate AI thinking delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'isUser': false,
            'text': 'Terima kasih atas pertanyaannya. Garda AI akan membantu Anda mencegah akses ke situs judi.'
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0F2F1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              _buildHeader(),

              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                       return _buildTypingIndicator();
                    }
                    if (index < _messages.length) {
                       final msg = _messages[index];
                       return _buildChatBubble(msg['text'], msg['isUser']);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Input Field
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C9A7), Color(0xFF00897B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/chatbot.png', 
              width: 40,
              height: 40,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GARDA AI',
                style: GoogleFonts.leagueSpartan(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Chatbot Assistant',
                style: GoogleFonts.leagueSpartan(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
             Image.asset('assets/images/chatbot.png', width: 35, height: 35),
             const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBEB), // Light Gray bubble
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(5),
                  bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(20),
                ),
                border: Border.all(color: Colors.black.withOpacity(0.8), width: 1), // Black border as seen in image
              ),
              child: Text(
                text,
                style: GoogleFonts.leagueSpartan(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
             const SizedBox(width: 8),
             const CircleAvatar(
               radius: 18,
               backgroundColor: Color(0xFF00E5FF),
               child: Icon(Icons.person, color: Colors.white, size: 20),
             ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
             Image.asset('assets/images/chatbot.png', width: 35, height: 35),
             const SizedBox(width: 8),
             Row(
               children: [1, 2, 3].map((e) => _BlinkingDot(delay: e * 200)).toList(),
             )
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 10,
             offset: const Offset(0, -5),
           )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                hintStyle: GoogleFonts.leagueSpartan(color: Colors.black38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: const Color(0xFF00C9A7),
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () => _handleSubmitted(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  final int delay;
  const _BlinkingDot({required this.delay});

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Slight delay for wave effect
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward(); 
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
         width: 8,
         height: 8,
         margin: const EdgeInsets.symmetric(horizontal: 2),
         decoration: const BoxDecoration(
           color: Colors.black45, // Slightly darker for visibility
           shape: BoxShape.circle,
         ),
      ),
    );
  }
}
