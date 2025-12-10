import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Logic default: False (Unprotected/Merah)
  bool isProtected = false; 
  bool hasData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light Gray background
      floatingActionButton: _buildChatBotButton(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Area (Map + Status)
            _buildHeader(),

            // 2. Content Body
            // Move up to overlap with the header transition
            Transform.translate(
              offset: const Offset(0, -60), // Adjusted offset for smoother overlap
              child: _buildContentBody(),
            ),
            
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 550, // Slightly taller for better crop
      width: double.infinity,
      child: Stack(
        children: [
          // Background Map
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                return Stack(
                  fit: StackFit.expand, // FORCE FILL: Ensures map size never changes
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: Image.asset(
                isProtected 
                    ? 'assets/images/Peta_Locked.png' 
                    : 'assets/images/Peta_Unlocked.png',
                key: ValueKey<bool>(isProtected),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity, // Explicitly force full width
                height: double.infinity, // Explicitly force full height
              ),
            ),
          ),
          
          // Gradients Logic
          // Top Gradient (Red for Unprotected, Green for Protected)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isProtected 
                      ? const Color(0xFF00C9A7).withOpacity(0.8) 
                      : Colors.red.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),


          // Bottom Gray Gradient (Fade into body content)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100, // Smoother fade
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF5F5F5).withOpacity(0.0),
                    const Color(0xFFF5F5F5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Status Text & Icon
          Positioned(
            top: 50, // Moved up to touch the top gradient slightly
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              // FIX: Anchor children to the TOP so they don't jump vertically
              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter, 
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: !isProtected
                  ? Column(
                      key: const ValueKey('unprotected'),
                      children: [
                        Image.asset(
                          'assets/images/unlock.png',
                          width: 40,
                          height: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                         Text(
                          'Anda tidak terproteksi dari Judi',
                          style: GoogleFonts.leagueSpartan(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 4.0,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '5700+ website judi ditemukan',
                            style: GoogleFonts.leagueSpartan(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('protected'),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user_outlined, color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Anda Terproteksi',
                              style: GoogleFonts.leagueSpartan(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Toggle Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isProtected
                    ? [const Color(0xFF00C9A7), const Color(0xFF00897B)] 
                    : [const Color(0xFFFF5252), const Color(0xFFD32F2F)], // Red Gradient
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERLINDUNGAN GARDA WARA',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isProtected 
                          ? 'Perlindungan Aman' 
                          : 'Perlindungan Tidak Aktif',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: isProtected,
                    onChanged: (val) {
                      setState(() {
                        isProtected = val;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF00B0FF), // Blue when active
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFFF5252), // Red when inactive
                    trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Disclaimer Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Garda Wara Memerlukan akses izin aksebilitas untuk mencegah membuka situs atau aplikasi judi',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Stats Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isProtected ? const Color(0xFFD0E8E2) : const Color(0xFFFFE0E0), 
              borderRadius: BorderRadius.circular(24),
              // Border removed to fix "garis item" issue
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading Stats
                Row(
                  children: [
                    Text(
                      isProtected ? (hasData ? '124' : '0') : '0',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Website Judi Terblokir',
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            isProtected 
                              ? 'Perlindungan Aman dengan AI Gardawara'
                              : 'Segera Aktifkan Gardawara',
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Divider(color: Colors.black87, thickness: 1.0), // Darker divider
                const SizedBox(height: 16),

                Text(
                  'Riwayat Pemblokiran',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),

                // Content Area
                if (isProtected)
                  if (hasData)
                    _buildBlockedList()
                  else
                    _buildEmptyStateProtected()
                else
                  _buildEmptyStateUnprotected(),
                  
                if (isProtected && hasData) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Lihat Selengkapnya',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateUnprotected() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Menggunakan gambar nosafe.png sesuai request user
          Image.asset(
            'assets/images/nosafe.png',
            width: 100, // Adjusted size
            height: 100,
          ),
          const SizedBox(height: 16),
          Text(
            'Segera Aktifkan Gardawara!',
            style: GoogleFonts.leagueSpartan(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildEmptyStateProtected() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Menggunakan gambar safe.png jika ada
          Image.asset(
            'assets/images/safe.png',
             width: 100,
             height: 100,
             errorBuilder: (ctx, _, __) => const Icon(
               Icons.verified_user_rounded, 
               size: 80, 
               color: Colors.green
             ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gardawara tidak mendeteksi apapun',
            style: GoogleFonts.leagueSpartan(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBlockedList() {
    final blockedSites = [
      {'url': 'slotgacor.com', 'time': '15:10, 22/10/2025'},
      {'url': 'slototo.com', 'time': '15:10, 22/10/2025'},
      {'url': 'gacor.com', 'time': '15:10, 22/10/2025'},
      {'url': 'toto.com', 'time': '15:10, 22/10/2025'},
      {'url': 'slot24.com', 'time': '15:10, 22/10/2025'},
      {'url': 'gacor21.com', 'time': '15:10, 22/10/2025'},
      {'url': 'gacor31.com', 'time': '15:10, 22/10/2025'},
    ];

    return Column(
      children: blockedSites.map((site) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                site['url']!,
                style: GoogleFonts.leagueSpartan(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  
                ),
              ),
              Text(
                site['time']!,
                style: GoogleFonts.leagueSpartan(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChatBotButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) => const ChatbotScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: Image.asset(
        'assets/images/chatbot.png',
        width: 80, 
        height: 80,
      ),
    );
  }
}
