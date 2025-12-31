import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/services/classifier_service.dart';
import 'settings_subscreens.dart';
import 'chatbot_screen.dart';

class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // --- LOGIC & SERVICES ---
  static const platform = MethodChannel('com.example.gardawara_ai/accessibility');
  final ClassifierService _classifier = ClassifierService();
  
  // LOGIC STATES
  bool _systemPermissionGranted = false; // Status asli dari OS
  bool _appProtectionActive = true;      // Status tombol di aplikasi (User Preference)
  
  // Master Status: Proteksi jalan HANYA JIKA izin sistem ada DAN user mengaktifkan di app
  bool get _isProtected => _systemPermissionGranted && _appProtectionActive;

  bool _isProcessing = false; // Debounce for AI
  int blockedCount = 0;
  int _accessAttempts = 0;
  DateTime? _startTime; 
  Timer? _activeTimer; 
  String _activeDuration = "0j 0m"; 
  List<Map<String, String>> _blockedHistory = [];

  // --- UI STATE ---
  int _currentIndex = 0;
  late VideoPlayerController _videoController;
  late AnimationController _animController;

  // --- COLORS ---
  final Color primaryDark = const Color(0xFF138066);
  final Color primaryLight = const Color(0xFF00E5C5);
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Setup AI & Channel
    _classifier.loadModel();
    platform.setMethodCallHandler(_nativeMethodCallHandler);
    
    // Load User Preference
    _loadPreferences();

    // Initialize Video immediately
    _initializeVideo(); 

    // Initial State Check (Async)
    _checkPermission();

    // UI Animations
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animController.forward();

    // Start UI timer
    _startUiTimer();
  }

  void _startUiTimer() {
    _activeTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_isProtected && _startTime != null) {
        final duration = DateTime.now().difference(_startTime!);
        setState(() {
          _activeDuration = "${duration.inHours}j ${duration.inMinutes % 60}m";
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _activeTimer?.cancel();
    if (_videoController.value.isInitialized) {
      _videoController.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permission when user comes back from Settings
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  // --- CORE LOGIC METHODS ---

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appProtectionActive = prefs.getBool('user_protection_active') ?? true;
    });
  }

  Future<void> _checkPermission() async {
    try {
      final bool result = await platform.invokeMethod('isAccessibilityEnabled');
      if (mounted) {
        if (_systemPermissionGranted != result) {
           setState(() {
            _systemPermissionGranted = result;
            _handleStatusChange();
          });
        }
      }
    } on PlatformException catch (_) {}
  }

  // Handle Logic when status changes
  void _handleStatusChange() {
    if (_isProtected) {
       if (_startTime == null) _startTime = DateTime.now();
    } else {
       _startTime = null;
       _activeDuration = "0j 0m";
    }
    _initializeVideo();
  }

  Future<void> _openSettings() async {
    try {
      await platform.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (_) {}
  }

  Future<dynamic> _nativeMethodCallHandler(MethodCall call) async {
    if (call.method == "onTextDetected") {
      if (_isProcessing) return;
      _isProcessing = true;

      final String text = call.arguments;

      if (!_isProtected) {
        _isProcessing = false;
        return;
      }

      // Increment access attempts
      if (mounted) {
          setState(() {
            _accessAttempts++; 
          });
      }

      bool isGambling = await _classifier.predict(text);

      if (isGambling) {
        debugPrint("⚠️ JUDI TERDETEKSI: $text");
        await platform.invokeMethod('performGlobalActionBack');

        if (mounted) {
          setState(() {
            blockedCount++;
            _blockedHistory.insert(0, {
              'url': text.length > 25 ? "${text.substring(0, 25)}..." : text,
              'time': DateFormat('HH:mm, dd/MM').format(DateTime.now()),
            });
            if (_blockedHistory.length > 10) _blockedHistory.removeLast();
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text("Gardawara memblokir konten mencurigakan!", style: GoogleFonts.leagueSpartan()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;
    }
  }

  // --- VIDEO HANDLING ---

  void _initializeVideo() {
    // Determine video source based on protection status
    // Default/Fail = failed.mp4
    // Success/Protected = success.mp4
    final String videoSource = _isProtected 
        ? "assets/video/success.mp4" 
        : "assets/video/failed.mp4";

    // Dispose previous controller if exists
    // Note: We need to handle this carefully to avoid UI flickering
    // Simple approach: create new, initialize, then setState
    
    // If controller exists, pause distinctively? No, just replace.
    
    _videoController = VideoPlayerController.asset(videoSource)
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
        setState(() {}); // Rebuild to show new video
      });
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildActivityTab(),
            _buildChatbotTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: primaryLight.withOpacity(0.3),
            labelTextStyle: MaterialStateProperty.all(
              GoogleFonts.leagueSpartan(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
            iconTheme: MaterialStateProperty.resolveWith((states) {
               if (states.contains(MaterialState.selected)) {
                 return IconThemeData(color: primaryDark);
               }
               return const IconThemeData(color: Colors.black45);
            }),
          ),
          child: NavigationBar(
            height: 65,
            backgroundColor: Colors.transparent,
            selectedIndex: _currentIndex,
            elevation: 0,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
                if (index == 0 || index == 3) {
                   _animController.reset();
                   _animController.forward();
                }
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
               NavigationDestination(
                icon: Icon(Icons.show_chart),
                selectedIcon: Icon(Icons.show_chart),
                label: 'Aktivitas',
              ),
               NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Chatbot',
              ),
               NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Pengaturan',
              ),
            ],
          ),
        ),
      );
  }

  // --- TAB 1: BERANDA ---
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center contents
        children: [
          _buildHeader(), // Simplified Header
          const SizedBox(height: 16), 
          _buildStatusCard(),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildSectionTitle('Ringkasan Statistik'),
          ),
          const SizedBox(height: 12),
          _buildStatsGrid(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return _buildAnimatedItem(
      delay: 0,
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Icon(Icons.shield_rounded, color: primaryDark, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              'Gardawara AI',
              style: GoogleFonts.leagueSpartan(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return _buildAnimatedItem(
      delay: 100,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            // Video Container - Full View (No Crop)
            Container(
              width: double.infinity,
              height: 200, // Balanced height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _videoController.value.isInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FittedBox(
                        fit: BoxFit.contain, // Ensure full video is visible
                        child: SizedBox(
                          width: _videoController.value.size.width,
                          height: _videoController.value.size.height,
                          child: VideoPlayer(_videoController),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
      
            const SizedBox(height: 16),
            
            // Status Text
            Text(
              _isProtected ? 'Status: Aman' : 'Status: Tidak Aman',
              style: GoogleFonts.leagueSpartan(
                color: _isProtected ? primaryDark : const Color(0xFFD32F2F),
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _isProtected 
                  ? 'AI aktif memblokir konten negatif' 
                  : 'Aktifkan proteksi untuk melindungi perangkat.',
                textAlign: TextAlign.center,
                style: GoogleFonts.leagueSpartan(
                  color: _isProtected ? Colors.grey[500] : const Color(0xFFE57373),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Toggle Button (Smart Toggle)
            GestureDetector(
              onTap: () async {
                if (!_systemPermissionGranted) {
                  // Jika izin sistem belum ada, buka pengaturan (Sekali saja)
                  _openSettings();
                } else {
                  // Jika izin sistem sudah ada, toggle internal langsung (Instant)
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _appProtectionActive = !_appProtectionActive;
                    prefs.setBool('user_protection_active', _appProtectionActive);
                    _handleStatusChange();
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: _isProtected 
                        ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)] 
                        : [const Color(0xFF10B981), const Color(0xFF047857)], 
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isProtected 
                          ? const Color(0xFFEF4444).withOpacity(0.3) 
                          : const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isProtected ? Icons.gpp_bad_outlined : Icons.shield_outlined, 
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isProtected ? 'Nonaktifkan Proteksi' : 'Aktifkan Proteksi',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return _buildAnimatedItem(
      delay: 200,
      child: Text(
        title,
        style: GoogleFonts.leagueSpartan(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return _buildAnimatedItem(
      delay: 300,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1, // Taller cards to prevent overflow
        children: [
          _buildStatCard('Situs Diblokir', blockedCount.toString(), Icons.block, const Color(0xFF6366F1)),
          // Real backend stats
          _buildStatCard('Aktivitas AI', _isProtected ? 'Aktif' : 'Nonaktif', Icons.psychology, _isProtected ? const Color(0xFFF59E0B) : Colors.grey),
          _buildStatCard('Waktu Aktif', _activeDuration, Icons.timer, const Color(0xFF10B981)),
          _buildStatCard('Upaya Akses', '$_accessAttempts', Icons.warning_amber_rounded, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  // --- OTHER TABS & HELPERS (Keep style consistent) ---

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Riwayat Pemblokiran', style: GoogleFonts.leagueSpartan(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (_blockedHistory.isEmpty)
             Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Icon(Icons.history, size: 50, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("Belum ada aktivitas.", style: GoogleFonts.leagueSpartan(color: Colors.grey)),
                ],
              ),
             )
          else
            Column(
              children: _blockedHistory.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.block, color: Colors.red, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['url'] ?? '-', style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(item['time'] ?? '-', style: GoogleFonts.leagueSpartan(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // --- TAB 3: CHATBOT (Integrated) ---
  Widget _buildChatbotTab() {
    // We wrap GardaChatScreen to fit within the tab structure.
    // Since GardaChatScreen has its own Scaffold, we might want to check its design.
    // However, for simplicity and modularity, we use it as is. 
    // If double scaffolds are an issue, consider refactoring GardaChatScreen to return just a Container/Column.
    // But for now, we'll assume it's fine or we can clip it.
    return const GardaChatScreen();
  }
  
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
         _buildAnimatedItem(delay: 0, child: Text('Pengaturan', style: GoogleFonts.leagueSpartan(fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 20),
        _buildAnimatedItem(delay: 100, child: _buildSettingItem('Notifikasi', true, true)),
        _buildAnimatedItem(delay: 150, child: _buildActionSettingItem('Whitelist', 'Kelola situs aman', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WhitelistBlacklistScreen())))),
        _buildAnimatedItem(delay: 200, child: _buildActionSettingItem('Laporan Aktivitas', 'Lihat detail', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityReportScreen())))),
        
        const SizedBox(height: 20),
        _buildAnimatedItem(
          delay: 250,
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePinScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: Row(children: [
                Icon(Icons.lock_reset, color: Colors.red[400]),
                const SizedBox(width: 12),
                Text('Ubah PIN', style: GoogleFonts.leagueSpartan(color: Colors.red, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ),
      ],
    ); 
  }

  Widget _buildAnimatedItem({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final Animation<double> animation = CurvedAnimation(
          parent: _animController,
          curve: Interval((delay / 1000).clamp(0.0, 1.0), ((delay + 500) / 1000).clamp(0.0, 1.0), curve: Curves.easeOut),
        );
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(offset: Offset(0, 20 * (1 - animation.value)), child: child),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding to prevent overflow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22), 
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: GoogleFonts.leagueSpartan(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.leagueSpartan(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, bool value, bool isSwitch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.leagueSpartan(fontSize: 16, fontWeight: FontWeight.w600)),
          if (isSwitch) Switch(value: value, onChanged: (val) {}, activeColor: primaryDark),
        ],
      ),
    );
  }

  Widget _buildActionSettingItem(String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.leagueSpartan(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GoogleFonts.leagueSpartan(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
