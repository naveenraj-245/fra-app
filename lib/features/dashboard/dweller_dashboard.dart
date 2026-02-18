import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Name
import 'package:provider/provider.dart';
import '../../language_provider.dart';

// Import your screens
import '../forms/claim_application_screen.dart';
import '../forms/grievance_screen.dart';
import '../chat/ai_chat_screen.dart';
import '../map/fra_map_screen.dart';
import 'tracking_screen.dart';
import 'rights_info_screen.dart';
import 'help_centers_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart'; // ✅ Import Profile Screen

class DwellerDashboard extends StatelessWidget {
  const DwellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final user = FirebaseAuth.instance.currentUser; // Get current user

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1B5E20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.translate('welcome_back'), style: const TextStyle(fontSize: 14, color: Colors.white70)),
            // 👇 STREAM BUILDER TO SHOW REAL NAME
            if (user != null)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    return Text(
                      data['name'] ?? "Forest Dweller", 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                    );
                  }
                  return const Text("Loading...", style: TextStyle(fontSize: 18, color: Colors.white));
                },
              )
            else 
              const Text("Guest", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          ),
          // 👇 PROFILE ICON BUTTON (Opens Profile Screen)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(Icons.person, color: Color(0xFF1B5E20)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATUS SECTION ---
            Text(lang.translate('claim_status'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // 1. LAND CLAIM CARD -> Goes to TrackingScreen
            _buildStatusCard(
              context,
              title: lang.translate('land_claim'),
              status: lang.translate('status_review'),
              color: Colors.orange,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen()));
              },
            ),

            const SizedBox(height: 10),

            // 2. FOREST PRODUCE CARD -> Goes to PermitScreen
            _buildStatusCard(
              context,
              title: lang.translate('forest_produce'),
              status: lang.translate('status_active'),
              color: Colors.green,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ForestPermitScreen()));
              },
            ),

            const SizedBox(height: 24),

            // --- QUICK ACTIONS GRID ---
            // Grievance Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[800],
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GrievanceScreen()),
                );
              },
              icon: const Icon(Icons.report_problem),
              label: const Text("File a Grievance"),
            ),
            Text(lang.translate('quick_actions'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1, 
              children: [
                _buildActionCard(context, lang.translate('apply_rights'), Icons.article, Colors.blue, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimApplicationScreen()))),
                _buildActionCard(context, lang.translate('track_status'), Icons.timeline, Colors.purple, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen()))),
                _buildActionCard(context, lang.translate('file_grievance'), Icons.gavel, Colors.redAccent, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrievanceScreen()))),
                _buildActionCard(context, lang.translate('get_help'), Icons.support_agent, Colors.teal, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen()))),
              ],
            ),

            const SizedBox(height: 24),

            // --- RESOURCES SECTION ---
            Text(lang.translate('resources'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RightsInfoScreen())),
              child: _buildResourceCard(
                "Know Your Rights", 
                "Learn about forest rights and legal protections", 
                Icons.menu_book, 
                Colors.indigo
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCentersScreen())),
              child: _buildResourceCard(
                "Find Help Centers", 
                "Locate nearby assistance centers and NGOs", 
                Icons.location_city, 
                Colors.brown
              ),
            ),
            
            const SizedBox(height: 40), 
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen())),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Already on Home
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FraMapScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
          } else if (index == 3) {
            // ✅ GO TO PROFILE SCREEN
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildStatusCard(BuildContext context, {required String title, required String status, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- PERMIT SCREEN PLACEHOLDER ---
class ForestPermitScreen extends StatelessWidget {
  const ForestPermitScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forest Permit"), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: const Center(child: Text("Permit Details Placeholder")),
    );
  }
}
