import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Standardized imports based on your project structure
import '../forms/claim_application_screen.dart';
import '../forms/grievance_screen.dart';
import '../chat/ai_chat_screen.dart';
import '../map/fra_map_screen.dart';
import 'tracking_screen.dart';
import 'rights_info_screen.dart'; // Ensure this file is created in the dashboard folder

class DwellerDashboard extends StatelessWidget {
  const DwellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1B5E20),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Good Morning,", style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text("Sky", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          // Logout Menu Logic
          PopupMenuButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF1B5E20)),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATUS SECTION ---
            const Text("Your Claim Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStatusCard("Land Claim - Forest Land", "Under Review", Colors.orange),
            const SizedBox(height: 10),
            _buildStatusCard("Forest Produce Permit", "Active", Colors.green),

            const SizedBox(height: 24),

            // --- QUICK ACTIONS GRID ---
            const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1, 
              children: [
                _buildActionCard(context, "Apply for Rights", Icons.article, Colors.blue, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimApplicationScreen()))),
                _buildActionCard(context, "Track Status", Icons.timeline, Colors.purple, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen()))),
                _buildActionCard(context, "File Grievance", Icons.gavel, Colors.redAccent, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrievanceScreen()))),
                _buildActionCard(context, "AI Support", Icons.support_agent, Colors.teal, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()))),
              ],
            ),

            const SizedBox(height: 24),

            // --- RESOURCES SECTION ---
            const Text("Resources", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            _buildResourceCard(
              "Find Help Centers", 
              "Locate nearby assistance centers and NGOs", 
              Icons.location_city, 
              Colors.brown
            ),
            
            const SizedBox(height: 40), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FraMapScreen()));
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

  // --- HELPER WIDGETS ---

  Widget _buildStatusCard(String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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