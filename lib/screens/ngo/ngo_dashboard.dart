import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Import your existing screens
import '../../features/forms/claim_application_screen.dart';
import '../../features/forms/grievance_screen.dart'; // NEW: Grievance support
import '../../features/dashboard/tracking_screen.dart';
import '../../features/dashboard/rights_info_screen.dart';
import '../../features/auth/role_selection_screen.dart';

class NgoDashboard extends StatefulWidget {
  const NgoDashboard({super.key});

  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  int _currentIndex = 0;

  // The 3 Tabs for the NGO
  final List<Widget> _tabs = [
    const NgoHomeTab(),
    const NgoMapTab(),
    const NgoProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4), // Light Teal Background
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF00695C), // Teal
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Community Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 1: HOME (Stats & Grid Actions)
// ==========================================
class NgoHomeTab extends StatelessWidget {
  const NgoHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('claims').where('userId', isEqualTo: user?.uid).snapshots(),
      builder: (context, snapshot) {
        int totalAssisted = 0;
        int approved = 0;
        int pending = 0;

        if (snapshot.hasData) {
          totalAssisted = snapshot.data!.docs.length;
          approved = snapshot.data!.docs.where((doc) => (doc.data() as Map)['status'] == 'Approved').length;
          pending = snapshot.data!.docs.where((doc) => (doc.data() as Map)['status'] == 'Pending').length;
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. WELCOME BANNER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF004D40), Color(0xFF00695C)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.handshake, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Welcome, Partner", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(user?.email ?? "NGO Representative", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // 2. STATS
                const Text("Your Community Impact", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard("Assisted", "$totalAssisted", Icons.people, Colors.blue),
                    const SizedBox(width: 10),
                    _buildStatCard("Approved", "$approved", Icons.check_circle, Colors.green),
                    const SizedBox(width: 10),
                    _buildStatCard("Pending", "$pending", Icons.hourglass_top, Colors.orange),
                  ],
                ),

                const SizedBox(height: 30),

                // 3. ACTION GRID
                const Text("Field Operations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionTile(context, "File Land Claim", "On behalf of dweller", Icons.post_add, const Color(0xFF00695C), () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimApplicationScreen()));
                    }),
                    _buildActionTile(context, "File Grievance", "Report land disputes", Icons.report_problem, Colors.red[700]!, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const GrievanceScreen()));
                    }),
                    _buildActionTile(context, "Track Claims", "Check approval status", Icons.track_changes, Colors.orange[700]!, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen()));
                    }),
                    _buildActionTile(context, "Educate Dwellers", "Show FRA guidelines", Icons.menu_book, Colors.blue[700]!, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RightsInfoScreen()));
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)], border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 24, child: Icon(icon, color: color, size: 26)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 2: MAP (Community Overview)
// ==========================================
class NgoMapTab extends StatelessWidget {
  const NgoMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community Zones"), backgroundColor: const Color(0xFF00695C), foregroundColor: Colors.white),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(11.4064, 76.6932), // Nilgiris default
          initialZoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.satyasetu.app', 
            maxNativeZoom: 19, 
            maxZoom: 22,       
          ),
          MarkerLayer(
            markers: [
              Marker(point: const LatLng(11.4064, 76.6932), width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.blue, size: 40)),
              Marker(point: const LatLng(11.4500, 76.7000), width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.orange, size: 40)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: const Text("Log Visit"),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Field visit logged securely.")));
        },
      ),
    );
  }
}

// ==========================================
// TAB 3: PROFILE
// ==========================================
class NgoProfileTab extends StatelessWidget {
  const NgoProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("NGO Profile"), backgroundColor: const Color(0xFF00695C), foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              decoration: const BoxDecoration(color: Color(0xFF00695C), borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.volunteer_activism, size: 50, color: Color(0xFF00695C))),
                  const SizedBox(height: 16),
                  const Text("VanAdhikar NGO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(user?.email ?? "ngo@test.com", style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfileMenu(Icons.business, "Organization Details", () {}),
                  _buildProfileMenu(Icons.language, "Language Options", () {}),
                  _buildProfileMenu(Icons.privacy_tip, "Data Security & Policies", () {}),
                  const Divider(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red[800], elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.logout),
                      label: const Text("Secure Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal[50], shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFF00695C))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen()), (route) => false);
    }
  }
}