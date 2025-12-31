import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

// Import model dan controller Anda
import '../controller/chatbot_controller.dart';
// Jika ChatBubble diletakkan di file terpisah, gunakan import ini:
// import 'package:gardawara_ai/model/chatbubble_model.dart';

class GardaChatScreen extends StatefulWidget {
  const GardaChatScreen({super.key});

  @override
  State<GardaChatScreen> createState() => _GardaChatScreenState();
}

class _GardaChatScreenState extends State<GardaChatScreen> {
  final ChatController _controller = ChatController();
  final String robotAssetPath = 'assets/images/robot.png';

  final Color primaryDark = const Color(0xFF138066);
  final Color primaryLight = const Color(0xFF00E5C5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.notifyListeners();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                if (_controller.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  controller: _controller.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount:
                      _controller.messages.length +
                      (_controller.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _controller.messages.length &&
                        _controller.isTyping) {
                      return _buildTypingIndicator();
                    }

                    final msg = _controller.messages[index];
                    return ChatBubble(
                      message: msg.text,
                      isBot: msg.isBot,
                      robotIconPath: robotAssetPath,
                      videoUrl: msg.videoUrl, // Fitur Video tetap dipertahankan
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
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              robotAssetPath,
              width: 35,
              height: 35,
              errorBuilder:
                  (_, __, ___) =>
                      Icon(Icons.smart_toy, color: primaryDark, size: 30),
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
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Image.asset(
              robotAssetPath,
              width: 80,
              height: 80,
              errorBuilder:
                  (_, __, ___) =>
                      Icon(Icons.smart_toy, size: 80, color: Colors.grey[300]),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Halo! Saya GardaBot.",
            style: GoogleFonts.leagueSpartan(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
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
                boxShadow: [
                  BoxShadow(
                    color: primaryDark.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
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
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
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
    width: 6,
    height: 6,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// --- WIDGET CHAT BUBBLE DENGAN DUKUNGAN VIDEO & GOOGLE FONTS ---
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isBot;
  final String robotIconPath;
  final String? videoUrl; // Tambahan fitur dari kodemu

  final Color primaryDark = const Color(0xFF138066);

  const ChatBubble({
    super.key,
    required this.message,
    required this.isBot,
    required this.robotIconPath,
    this.videoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Image.asset(
                robotIconPath,
                errorBuilder:
                    (_, __, ___) =>
                        Icon(Icons.smart_toy, size: 20, color: primaryDark),
              ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pesan Markdown
                  MarkdownBody(
                    data: message,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.leagueSpartan(
                        color: isBot ? Colors.black87 : Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // Tampilkan Video jika ada (Fitur Anda)
                  if (videoUrl != null && videoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _VideoPreview(url: videoUrl!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget video yang bisa di-play/pause dan fullscreen
class _VideoPreview extends StatefulWidget {
  final String url;
  const _VideoPreview({required this.url});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoPlayerController _vController;
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _vController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _vController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_vController.value.isPlaying) {
        _vController.pause();
        _isPlaying = false;
      } else {
        _vController.play();
        _isPlaying = true;
      }
    });
  }

  void _openFullScreen() {
    _vController.pause(); // Pause preview saat fullscreen
    setState(() => _isPlaying = false);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(url: widget.url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox(
        height: 150,
        child: Center(
            child: CircularProgressIndicator(color: Color(0xFF138066))),
      );
    }

    return Container(
      width: 250, // Batasi lebar agar rapi di bubble
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _vController.value.aspectRatio,
              child: VideoPlayer(_vController),
            ),
            // Tombol Play/Pause Overlay
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                color: Colors.transparent, // Hitbox
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Tombol Fullscreen di pojok kanan bawah
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _openFullScreen,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String url;
  const FullScreenVideoPlayer({super.key, required this.url});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Allow landscape rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play(); // Auto play saat fullscreen
        });
      });
  }

  @override
  void dispose() {
    // Revert to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            // Tap area untuk toggle controls
            GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
            // Controls Overlay
            if (_showControls) ...[
              // Back Button
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Play/Pause Center
              if (_isInitialized)
                Center(
                  child: IconButton(
                    iconSize: 60,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                  ),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
