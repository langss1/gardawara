import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logpeople_screen.dart';
import 'new_screen.dart';
import 'setup_screen.dart';
import 'loguser_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final Color primaryGreen = const Color(0xFF4ADE80);
  final Color darkGreen = const Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onOptionSelected(String type) {
    if (type == 'guardian') {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) => const LogPeopleScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
             // Effect "Melebar": Scale up from center
             var curve = Curves.easeOutExpo;
             var scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: curve));
             var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

             return FadeTransition(
               opacity: fadeAnimation,
               child: ScaleTransition(
                 scale: scaleAnimation,
                 child: child,
               ),
             );
          },
        ),
      );
    } else if (type == 'user') {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) => const LogUserScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
             var curve = Curves.easeOutExpo;
             var scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: curve));
             var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

             return FadeTransition(
               opacity: fadeAnimation,
               child: ScaleTransition(
                 scale: scaleAnimation,
                 child: child,
               ),
             );
          },
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmallScreen ? 10 : 20),

              // 1. Back Button
              _buildAnimatedWidget(
                delay: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 600),
                        pageBuilder: (context, animation, secondaryAnimation) => const NewScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                           const begin = Offset(-1.0, 0.0); 
                           const end = Offset.zero;
                           const curve = Curves.easeInOutQuart;
                           var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                           var offsetAnimation = animation.drive(tween);
                           return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.black87),
                      const SizedBox(width: 8),
                      Text(
                        'kembali',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: isSmallScreen ? 15 : 25), 

              // 2. Title Section
              _buildAnimatedWidget(
                delay: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siapa yang menggunakan?',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: isSmallScreen ? 22 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih tipe pengguna untuk melanjutkan',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1), 

              // 3. Choice Cards
              Expanded(
                flex: 12, 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  children: [
                    _buildAnimatedWidget(
                      delay: 400,
                      child: _buildUserTypeCard(
                        icon: Icons.volunteer_activism_outlined,
                        title: 'Orang Terdekat',
                        description: 'Akses penuh pantau & atur proteksi', 
                        points: ['Lihat statistik & laporan', 'Atur proteksi'],
                        onTap: () => _onOptionSelected('guardian'),
                        isSmall: isSmallScreen,
                      ),
                    ),
                    _buildAnimatedWidget(
                      delay: 550,
                      child: _buildUserTypeCard(
                        icon: Icons.person_outline,
                        title: 'Pengguna',
                        description: 'Akses terbatas, proteksi selalu aktif',
                        points: ['Proteksi tak bisa mati', 'Internet aman'], 
                        onTap: () => _onOptionSelected('user'),
                        isSmall: isSmallScreen,
                      ),
                    ),
                    _buildAnimatedWidget(
                      delay: 700,
                      child: _buildUserTypeCard(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Custom', 
                        description: 'Akses penuh atur semua fitur',
                        points: ['Atur proteksi', 'Internet aman terkontrol'],
                        onTap: () => _onOptionSelected('custom'),
                        isSmall: isSmallScreen,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 4. Footer
              _buildAnimatedWidget(
                delay: 900,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Mendukung kampanye nasional lawan judi online',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Image.asset(
                        'assets/images/judi pasti rugi.png',
                        height: isSmallScreen ? 30 : 40,
                        filterQuality: FilterQuality.high,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedWidget({required Widget child, required int delay}) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay / 1500,
            (delay + 600) / 1500 > 1.0 ? 1.0 : (delay + 600) / 1500,
            curve: Curves.easeOutQuart,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay / 1500,
              (delay + 600) / 1500 > 1.0 ? 1.0 : (delay + 600) / 1500,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildUserTypeCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> points,
    required VoidCallback onTap,
    required bool isSmall,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [primaryGreen, darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isSmall ? 14 : 16), 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmall ? 8 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.1)),
                  ),
                  child: Icon(icon, color: Colors.black87, size: isSmall ? 24 : 28),
                ),
                const SizedBox(width: 14),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: isSmall ? 15 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: isSmall ? 11 : 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Bullet Points
                      ...points.map((point) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '\u2022 ', 
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    point,
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.leagueSpartan(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
