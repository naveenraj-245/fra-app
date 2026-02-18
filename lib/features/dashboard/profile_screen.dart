import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart'; 
import 'tracking_screen.dart'; // Links to your tracking screen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String contactInfo = user?.phoneNumber ?? user?.email ?? "Unknown User";

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light green background
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: const Color(0xFF1B5E20), // Forest Green
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. PROFILE HEADER
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 60, color: Color(0xFF1B5E20)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 16, color: Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Forest Dweller", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(user?.phoneNumber != null ? Icons.phone : Icons.email, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(contactInfo, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // ==========================================
            // 2. MY ACTIVITY SECTION
            // ==========================================
            _buildSectionTitle("My Activity"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuOption(
                    icon: Icons.track_changes, 
                    title: "Track My Claims", 
                    subtitle: "Check approval status",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen()));
                    }
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==========================================
            // 3. ACCOUNT SETTINGS SECTION
            // ==========================================
            _buildSectionTitle("Account Settings"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuOption(
                    icon: Icons.language, 
                    title: "App Language", 
                    subtitle: "Choose your preferred language",
                    onTap: () => _showLanguageSheet(context)
                  ),
                  _buildMenuOption(
                    icon: Icons.privacy_tip_outlined, 
                    title: "Data Privacy & Security", 
                    subtitle: "How we protect your data",
                    onTap: () => _showPrivacyDialog(context)
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==========================================
            // 4. SUPPORT SECTION
            // ==========================================
            _buildSectionTitle("Support"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuOption(
                    icon: Icons.support_agent, 
                    title: "Toll-Free Helpline", 
                    subtitle: "Call for Govt Assistance",
                    onTap: () => _showHelplineDialog(context)
                  ),
                  
                  const Divider(height: 40, thickness: 1),

                  // ==========================================
                  // 5. LOGOUT BUTTON
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[800],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Log Out Securely", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMenuOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF1B5E20)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ==========================================
  // BUTTON ACTION METHODS
  // ==========================================

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            ListTile(title: const Text("English"), trailing: const Icon(Icons.check, color: Colors.green), onTap: () => Navigator.pop(ctx)),
            ListTile(title: const Text("தமிழ் (Tamil)"), onTap: () => Navigator.pop(ctx)),
            ListTile(title: const Text("हिन्दी (Hindi)"), onTap: () => Navigator.pop(ctx)),
            ListTile(title: const Text("ଓଡ଼ିଆ (Odia)"), onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [Icon(Icons.security, color: Colors.green), SizedBox(width: 10), Text("Data Privacy")],
        ),
        content: const Text(
          "Your data is 100% secure.\n\n"
          "• Land coordinates are encrypted.\n"
          "• ID documents are stored on secure Govt servers.\n"
          "• We do not share your information with third parties.",
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("I Understand", style: TextStyle(color: Color(0xFF1B5E20)))),
        ],
      ),
    );
  }

  void _showHelplineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [Icon(Icons.phone_in_talk, color: Color(0xFF1B5E20)), SizedBox(width: 10), Text("Govt Helpline")],
        ),
        content: const Text(
          "For any questions regarding your Forest Rights Act application, please call our toll-free number.\n\n📞 1800-111-2222\n\nAvailable Mon-Sat (9 AM to 6 PM)."
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx), 
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
            child: const Text("Call Now"),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out of your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen(userRole: 'dweller')), (route) => false);
              }
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }
}