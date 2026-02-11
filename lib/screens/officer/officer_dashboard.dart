import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/login_screen.dart';
import '../../features/forms/claim_application_screen.dart';
import '../../features/map/fra_map_screen.dart'; // For the Map Tab
import 'package:cloud_firestore/cloud_firestore.dart';
import 'application_details.dart'; // To open the claim when clicked
import 'applications_list.dart'; // To link the "Reviews" tab

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
        int pending = docs.where((d) => d['status'] == 'Pending').length;
        int approved = docs.where((d) => d['status'] == 'Approved').length;
        int rejected = docs.where((d) => d['status'] == 'Rejected').length;

        // 3. GET RECENT TASKS (Top 3)
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
                        
                        // 2. LIVE TASKS LIST
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Recent Claims", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () {
                                // Switch to Tab 2 (handled by parent controller in real app, or user taps tab)
                              }, 
                              child: const Text("View All")
                            ),
                          ],
                        ),
                        
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
                            data['status'],
                            getStatusColor(data['status']),
                            data, // Pass full data for details screen
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5)],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(Icons.assignment, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        onTap: () {
          // Open Details Screen
          // Convert dynamic map to Map<String, String> for the existing screen
          // (In a real app, update the model to handle dynamic types better)
          Map<String, String> safeData = data.map((key, value) => MapEntry(key, value.toString()));
          
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => ApplicationDetailsScreen(claimData: safeData))
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
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
             await FirebaseAuth.instance.signOut();
             if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen(userRole: 'officer')), (route) => false);
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}