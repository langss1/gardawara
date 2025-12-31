import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'guardian_home_screen.dart';

class LogPeopleScreen extends StatefulWidget {
  const LogPeopleScreen({super.key});

  @override
  State<LogPeopleScreen> createState() => _LogPeopleScreenState();
}

class _LogPeopleScreenState extends State<LogPeopleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  // Controllers for the 4 pin inputs
  final List<TextEditingController> _controllers = 
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  // Colors
  final Color primaryGreen = const Color(0xFF4ADE80);
  final Color darkGreen = const Color(0xFF22C55E);
  final Color boxColor = const Color(0xFFA6E8AC); // Light green box

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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _submitCode() {
    String pin = _controllers.map((c) => c.text).join();
    if (pin.length == 4) {
       // Navigate to new Dashboard
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GuardianHomeScreen()),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 4 digit PIN')),
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

              SizedBox(height: isSmallScreen ? 20 : 30),

              // 2. Headings
              _buildAnimatedWidget(
                delay: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Masukkan Pin Pengguna',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan 4 digit pin',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 30 : 50),

              // 3. Pin Input Area
              _buildAnimatedWidget(
                delay: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'GW - ',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32), // Dark green to match theme
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(4, (index) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            width: 46, // Reduced to prevent overflow
                            height: 65,
                            decoration: BoxDecoration(
                              color: boxColor,
                              borderRadius: BorderRadius.circular(12), // Softer corners
                              border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5), // Subtle border
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Center(
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 28, 
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B5E20), // Dark green text
                                ),
                                decoration: const InputDecoration(
                                  counterText: "",
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 3) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        )
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isSmallScreen ? 30 : 50),

              // 4. Submit Button
              _buildAnimatedWidget(
                delay: 600,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [const Color(0xFF32F56C), const Color(0xFF22C55E)], // Very bright green start
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.black87, width: 1.5) // Thin border as per design
                  ),
                  child: ElevatedButton(
                    onPressed: _submitCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                        textAlign: TextAlign.center,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.asset(
                        'assets/images/judi pasti rugi.png',
                        height: 35,
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
    // Fade & Slide Animation
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay / 1000,
            (delay + 400) / 1000 > 1.0 ? 1.0 : (delay + 400) / 1000,
            curve: Curves.easeOutQuart,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay / 1000,
              (delay + 400) / 1000 > 1.0 ? 1.0 : (delay + 400) / 1000,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
