import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class LogUserScreen extends StatefulWidget {
  const LogUserScreen({super.key});

  @override
  State<LogUserScreen> createState() => _LogUserScreenState();
}

class _LogUserScreenState extends State<LogUserScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 1. Back Button
               _buildAnimatedWidget(
                delay: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
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

              const SizedBox(height: 40),

              // 2. Headings
              _buildAnimatedWidget(
                delay: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Automatic Pin',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Salin kode ini untuk di tempel ke orang terdekat',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. PIN Code Box
              _buildAnimatedWidget(
                delay: 400,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8E6A6), // Light Green
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '5 7 6 8',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                           Clipboard.setData(const ClipboardData(text: "5768"));
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Text('Kode disalin!', style: GoogleFonts.leagueSpartan()),
                               backgroundColor: const Color(0xFF22C55E),
                             )
                           );
                        },
                        child: Text(
                          'salin kode',
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Masuk Button
              _buildAnimatedWidget(
                delay: 600,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action for 'Masuk' - maybe pop or go somewhere?
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22FF46), // Bright neon green
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black, width: 1.2),
                      ),
                    ),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 5. Footer
              _buildAnimatedWidget(
                delay: 800,
                child: Center(
                  child: Column(
                    children: [
                       Text(
                        'Mendukung kampanye nasional lawan judi online',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/judi pasti rugi.png',
                        height: 35,
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
        begin: const Offset(0, 0.2), 
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
              delay / 1500, // staggered start
              (delay + 500) / 1500 > 1.0 ? 1.0 : (delay + 500) / 1500,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
