import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/login_screen.dart';
import '../../features/forms/claim_application_screen.dart';
import '../../features/map/fra_map_screen.dart'; // For the Map Tab
import 'package:cloud_firestore/cloud_firestore.dart';
import 'application_details.dart'; // To open the claim when clicked
import 'applications_list.dart'; // To link the "Reviews" tab
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OfficerHomeTab(),
    const FraMapScreen(isOfficerMode: true),
    const ApplicationsListScreen(),
    const OfficerProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1), // Cool Grey Background
      body: _pages[_currentIndex],
      
      // FLOATING ACTION BUTTON (Assisted Mode)
      floatingActionButton: _currentIndex == 0 
        ? FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const ClaimApplicationScreen(isAssisted: true))
              );
            },
            backgroundColor: const Color(0xFF0D47A1), // Navy Blue
            icon: const Icon(Icons.assignment_add, color: Colors.white),
            label: const Text("New Assisted Claim", style: TextStyle(color: Colors.white)),
          )
        : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Overview"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: "Field Map"),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open_outlined), activeIcon: Icon(Icons.folder_open), label: "Reviews"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// =================================================================
// 1. HOME TAB (THE "COMMAND CENTER")
// =================================================================
class OfficerHomeTab extends StatelessWidget {
  const OfficerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. LISTEN TO CLAIM DATA STREAM
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('claims').orderBy('submittedAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var docs = snapshot.data!.docs;
        
        // 2. CALCULATE STATS
        int pending = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'Pending').length;
        int approved = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'Approved').length;
        int rejected = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'Rejected').length;

        // 3. EXTRACT LIVE MAP MARKERS
        List<Marker> mapMarkers = [];
        for (var doc in docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data['location'] != null && data['location'] is GeoPoint) {
            GeoPoint pos = data['location'];
            mapMarkers.add(
              Marker(
                point: LatLng(pos.latitude, pos.longitude),
                width: 24,
                height: 24,
                child: Icon(Icons.location_on, color: getStatusColor(data['status'] ?? 'Pending'), size: 24),
              )
            );
          }
        }

        // 4. GET RECENT TASKS (Top 3)
        var recentClaims = docs.take(3).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFECEFF1),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // A. APP BAR
                SliverAppBar(
                  backgroundColor: const Color(0xFF0D47A1),
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    title: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Divisional Officer • Zone A", style: TextStyle(fontSize: 10, color: Colors.white70)),
                        Text("Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    background: Container(color: const Color(0xFF0D47A1)),
                  ),
                ),

                // B. LIVE CONTENT
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. REAL STATS GRID
                        const Text("Live Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildStatCard("Pending", "$pending", Colors.orange, Icons.hourglass_empty),
                            const SizedBox(width: 10),
                            _buildStatCard("Approved", "$approved", Colors.green, Icons.check_circle),
                            const SizedBox(width: 10),
                            _buildStatCard("Rejected", "$rejected", Colors.red, Icons.cancel),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // 2. LIVE FIELD MAP PREVIEW (Replaced Image with Real Map)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Field Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FraMapScreen(isOfficerMode: true))), 
                              child: const Text("Expand View")
                            ),
                          ],
                        ),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: const LatLng(11.4064, 76.6932), // Default center (Nilgiris)
                                initialZoom: 11.0,
                                // Disable gestures on the mini-map so it doesn't interrupt scrolling
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                                onTap: (_, __) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FraMapScreen(isOfficerMode: true)));
                                }
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.satyasetu.app',
                                ),
                                MarkerLayer(markers: mapMarkers),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 3. LIVE TASKS LIST
                        const Text("Recent Claims", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        
                        if (recentClaims.isEmpty)
                           const Padding(
                             padding: EdgeInsets.all(20.0),
                             child: Text("No claims submitted yet."),
                           ),

                        ...recentClaims.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return _buildTaskTile(
                            context,
                            data['applicantName'] ?? "Unknown", 
                            "${data['type']} • ${data['area']} Acres", 
                            data['status'] ?? 'Pending',
                            getStatusColor(data['status'] ?? 'Pending'),
                            data, 
                          );
                        }),

                        const SizedBox(height: 80), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- HELPER FUNCTIONS ---

  Color getStatusColor(String status) {
    if (status == 'Approved') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(top: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, String title, String subtitle, String status, Color color, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.assignment, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        onTap: () {
          // Open Details Screen
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => ApplicationDetailsScreen(claimData: data))
          );
        },
      ),
    );
  }
}

// =================================================================
// 2. OTHER TABS (Placeholders)
// =================================================================

class OfficerApplicationsTab extends StatelessWidget {
  const OfficerApplicationsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Applications"), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
      body: const Center(child: Text("Full Searchable List Here")),
    );
  }
}

class OfficerProfileTab extends StatelessWidget {
  const OfficerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Officer Profile"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER (ID CARD STYLE)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 50, color: Color(0xFF0D47A1)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Divisional Forest Officer",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "officer@gov.in",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: const Text("Zone A - Nilgiris District", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. SETTINGS LIST (NOW FUNCTIONAL)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfileMenu(Icons.assignment_turned_in, "My Approvals History", () {
                    // Navigate to the list screen
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationsListScreen()));
                  }),
                  _buildProfileMenu(Icons.gavel, "Zone Jurisdictions", () => _showZoneDialog(context)),
                  _buildProfileMenu(Icons.language, "Language Preferences", () => _showLanguageSheet(context)),
                  _buildProfileMenu(Icons.security, "Change Password", () => _resetPassword(context, user?.email)),
                  _buildProfileMenu(Icons.help_outline, "Help & Support", () => _showSupportDialog(context)),
                  
                  const Divider(height: 40),

                  // 3. LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[800],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text("Log Out securely", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  // --- MENU WIDGET HELPER ---
  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF0D47A1)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ==========================================
  // BUTTON ACTION METHODS
  // ==========================================

  // 1. Zone Jurisdictions Dialog
  void _showZoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.map, color: Color(0xFF0D47A1)), SizedBox(width: 10), Text("Assigned Zones")],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You are authorized to review claims in:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("• Mudumalai Buffer Zone\n• Kotagiri Forest Range\n• Gudalur Division"),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
      ),
    );
  }

  // 2. Language Preferences Sheet
  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select App Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(title: const Text("English"), trailing: const Icon(Icons.check, color: Colors.green), onTap: () => Navigator.pop(ctx)),
            ListTile(title: const Text("தமிழ் (Tamil)"), onTap: () => Navigator.pop(ctx)),
            ListTile(title: const Text("हिन्दी (Hindi)"), onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  // 3. Real Password Reset via Firebase
  void _resetPassword(BuildContext context, String? email) {
    if (email == null) return;
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent!"), backgroundColor: Colors.green),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
      );
    });
  }

  // 4. Help & Support Dialog
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.support_agent, color: Color(0xFF0D47A1)), SizedBox(width: 10), Text("IT Support")],
        ),
        content: const Text("For technical issues or dashboard access problems, please contact the IT Admin desk.\n\nEmail: admin@satyasetu.gov.in\nPhone: 1800-111-2222"),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  // 5. Secure Logout
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to exit your official session?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                // Adjust route to match your app's login screen
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen(userRole: 'officer')), (route) => false);
              }
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }
}