import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER SECTION (Green Background + Profile Pic)
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Green Background
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B5E20),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Title
                Positioned(
                  top: 60,
                  child: Text(
                    "My Profile",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                // Profile Picture (Overlapping)
                Positioned(
                  bottom: -50,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage('assets/images/user_avatar.png'), // Add an image or use Icon below
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // 2. NAME & ID INFO
            Text(
              "Sky", // Replace with user.displayName
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Text("Irula Tribe • Nilgiris District", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
            ),

            const SizedBox(height: 30),

            // 3. STATS ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard("Claims", "1", Colors.orange),
                  const SizedBox(width: 15),
                  _buildStatCard("Permits", "2", Colors.green),
                  const SizedBox(width: 15),
                  _buildStatCard("Status", "Good", Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 4. PERSONAL DETAILS CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.perm_identity, "Aadhar Number", "XXXX-XXXX-8899", null),
                  const Divider(height: 1),
                  _buildListTile(Icons.phone, "Phone Number", "+91 98765 43210", null),
                  const Divider(height: 1),
                  _buildListTile(Icons.home, "Address", "No. 12, Forest Edge, Ooty", null),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 5. SETTINGS SECTION
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.language, "Language", "English (Change)", () {
                     // Add language dialog logic here if needed
                  }),
                  const Divider(height: 1),
                  _buildListTile(Icons.download_for_offline, "Offline Maps", "Downloaded (50MB)", () {}),
                  const Divider(height: 1),
                  _buildListTile(Icons.logout, "Logout", "Sign out of account", () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pop(context); // Go back to login
                    }
                  }, isDestructive: true),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, VoidCallback? onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF1B5E20)),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDestructive ? Colors.red : Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) : null,
      onTap: onTap,
    );
  }
}
