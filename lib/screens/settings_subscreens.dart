import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color Palette (Matched with GuardianHomeScreen)
final Color primaryDark = const Color(0xFF138066);
final Color primaryLight = const Color(0xFF00E5C5);

// 1. Whitelist / Blacklist Screen
class WhitelistBlacklistScreen extends StatefulWidget {
  const WhitelistBlacklistScreen({super.key});

  @override
  State<WhitelistBlacklistScreen> createState() => _WhitelistBlacklistScreenState();
}

class _WhitelistBlacklistScreenState extends State<WhitelistBlacklistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _addController = TextEditingController();

  // Mutable lists for interaction
  List<String> whitelist = ['habb_education.com', 'google.com', 'wikipedia.org'];
  List<String> blacklist = ['unknown-site.xyz', 'gambling-site.net', 'ads-tracker.io'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addController.dispose();
    super.dispose();
  }

  void _addItem(bool isWhitelist) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isWhitelist ? 'Tambah Whitelist' : 'Tambah Blacklist', style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _addController,
            decoration: InputDecoration(
              hintText: 'Masukkan URL (contoh: site.com)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.leagueSpartan(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_addController.text.isNotEmpty) {
                  setState(() {
                    if (isWhitelist) {
                      whitelist.insert(0, _addController.text);
                    } else {
                      blacklist.insert(0, _addController.text);
                    }
                  });
                  _addController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Tambah', style: GoogleFonts.leagueSpartan(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _removeItem(bool isWhitelist, int index) {
    setState(() {
      if (isWhitelist) {
        whitelist.removeAt(index);
      } else {
        blacklist.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Kelola Situs', style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryDark,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryDark,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Whitelist (Izinkan)'),
            Tab(text: 'Blacklist (Blokir)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(whitelist, true),
          _buildList(blacklist, false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           // Determine which tab is active
           _addItem(_tabController.index == 0);
        },
        backgroundColor: primaryDark,
        icon: const Icon(Icons.add_link),
        label: Text("Tambah Situs", style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildList(List<String> items, bool isWhitelist) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("Belum ada situs terdaftar.", style: GoogleFonts.leagueSpartan(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isWhitelist ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWhitelist ? Icons.check_circle : Icons.block, 
                color: isWhitelist ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: Text(items[index], style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.w600, fontSize: 15)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => _removeItem(isWhitelist, index),
            ),
          ),
        );
      },
    );
  }
}

// 2. Activity Report Screen
class ActivityReportScreen extends StatelessWidget {
  final List<Map<String, String>> history;
  final int blockedCount;

  const ActivityReportScreen({
    super.key, 
    this.history = const [], 
    this.blockedCount = 0
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Laporan & Riwayat', style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: history.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Belum ada riwayat aktivitas.", style: GoogleFonts.leagueSpartan(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: history.length + 1, // +1 for the summary header
            itemBuilder: (context, index) {
              if (index == 0) {
                 return Container(
                   margin: const EdgeInsets.only(bottom: 20),
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: primaryDark,
                     borderRadius: BorderRadius.circular(16),
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("Total Diblokir", style: GoogleFonts.leagueSpartan(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                       Text("$blockedCount Situs", style: GoogleFonts.leagueSpartan(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                     ],
                   ),
                 );
              }
              final item = history[index - 1];
              return _buildReportItem(
                "Blokir Konten", 
                "${item['url']} mencoba diakses", 
                item['time'] ?? 'Baru saja', 
                Colors.red
              );
            },
          ),
    );
  }

  Widget _buildReportItem(String title, String desc, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.block, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: GoogleFonts.leagueSpartan(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.leagueSpartan(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}

// 3. Change PIN Screen
class ChangePinScreen extends StatelessWidget {
  const ChangePinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Ubah PIN', style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_reset, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              'Perbarui PIN Keamanan',
              style: GoogleFonts.leagueSpartan(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan PIN baru mudah diingat namun sulit ditebak.',
              textAlign: TextAlign.center,
              style: GoogleFonts.leagueSpartan(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 40),
            _buildPinField("PIN Lama", false),
            const SizedBox(height: 20),
            _buildPinField("PIN Baru", true),
            const SizedBox(height: 20),
            _buildPinField("Konfirmasi PIN Baru", true),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PIN Berhasil Diubah', style: GoogleFonts.leagueSpartan()),
                      backgroundColor: primaryDark,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  elevation: 5,
                  shadowColor: primaryDark.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Simpan Perubahan', style: GoogleFonts.leagueSpartan(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField(String label, bool isNew) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          keyboardType: TextInputType.number,
          style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2),
          decoration: InputDecoration(
            hintText: "••••",
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: isNew ? const Icon(Icons.visibility_off_outlined, color: Colors.grey) : null,
          ),
        ),
      ],
    );
  }
}
