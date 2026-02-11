import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light Grey Background
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          // Default Data (while loading or if missing)
          String name = "Loading...";
          String phone = "+91 --";
          String email = "dweller@forest.com";

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? "Forest Dweller";
            phone = data['phone'] ?? "+91 98765 43210";
            email = data['email'] ?? "email@example.com";
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. GREEN HEADER SECTION WITH OVERLAPPING AVATAR
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Green Background Curve
                    Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B5E20),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    // Avatar (Positioned halfway out)
                    Positioned(
                      bottom: -50,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          // ✅ FIX: Uses Text Initials instead of Image to prevent crash
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "U",
                            style: const TextStyle(
                              fontSize: 40, 
                              color: Colors.grey, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 60), // Space for the avatar

                // 2. NAME & TAGLINE
                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    "Irula Tribe • Nilgiris District",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 25),

                // 3. STATS ROW (3 Cards)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard("1", "Claims", Colors.orange),
                      const SizedBox(width: 12),
                      _buildStatCard("2", "Permits", Colors.green),
                      const SizedBox(width: 12),
                      _buildStatCard("Good", "Status", Colors.blue),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 4. PERSONAL DETAILS CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _buildListTile(Icons.perm_identity, "Aadhar Number", "XXXX-XXXX-8899", showDivider: true),
                      _buildListTile(Icons.phone, "Phone Number", phone, showDivider: true),
                      _buildListTile(Icons.email, "Email", email, showDivider: true),
                      _buildListTile(Icons.home, "Address", "No. 12, Forest Edge, Ooty", showDivider: false),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. SETTINGS & LOGOUT CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(Icons.language, "Language", "English (Change)"),
                      const Divider(height: 1, indent: 60, endIndent: 20),
                      _buildSettingsTile(Icons.download_for_offline, "Offline Maps", "Downloaded (50MB)"),
                      const Divider(height: 1, indent: 60, endIndent: 20),
                      
                      // LOGOUT BUTTON
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.logout, color: Colors.red, size: 20),
                        ),
                        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        subtitle: const Text("Sign out of account", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            // Navigate back to Login and remove all previous routes
                            Navigator.pushAndRemoveUntil(
                              context,
                              // ✅ Ensures we default back to 'dweller' login on logout
                              MaterialPageRoute(builder: (_) => const LoginScreen(userRole: 'dweller')),
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, {required bool showDivider}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF1B5E20), size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        if (showDivider) const Divider(height: 1, indent: 60, endIndent: 20),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}
