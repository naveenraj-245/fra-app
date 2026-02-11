import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/login_screen.dart';
import '../../features/forms/claim_application_screen.dart'; // Reuse the form

class NgoDashboard extends StatefulWidget {
  const NgoDashboard({super.key});

  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Light Orange Background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFE65100), // 🟠 ORANGE (NGO Theme)
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Social Worker / NGO", style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text("Community Helper", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen(userRole: 'ngo')));
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. WELCOME BANNER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFEF6C00), Color(0xFFFFA726)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volunteer_activism, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome, Volunteer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("You have helped 24 families secure their rights.", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. ACTION BUTTONS
            Row(
              children: [
                _buildActionCard(
                  icon: Icons.person_add, 
                  label: "New Claim", 
                  color: Colors.orange,
                  onTap: () {
                    // Open the Assisted Form
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const ClaimApplicationScreen(isAssisted: true))
                    );
                  }
                ),
                const SizedBox(width: 16),
                _buildActionCard(
                  icon: Icons.history, 
                  label: "History", 
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to a simple list view
                  }
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. RECENTLY HELPED LIST
            const Text("Pending Applications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStatusTile("Ravi Kumar", "Submitted 2 days ago", "Pending", Colors.orange),
            _buildStatusTile("Sita Devi", "Submitted 5 days ago", "Approved", Colors.green),
            _buildStatusTile("Muthu Vel", "Missing Documents", "Rejected", Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTile(String name, String time, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.grey[200], child: Text(name[0])),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}