import 'package:flutter/material.dart';
import 'login_screen.dart'; // We will create this next

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        title: const Text("Satya-Shield"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20), // Forest Green
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // We will add language logic later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Language settings coming soon!")),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Who are you?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Select your role to continue.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // 1. Forest Dweller Card
            _buildRoleCard(
              context,
              title: "Forest Dweller",
              icon: Icons.person_pin_circle,
              color: Colors.green.shade700,
              onTap: () => _navigateToLogin(context, "dweller"),
            ),
            
            const SizedBox(height: 20),

            // 2. Government Officer Card
            _buildRoleCard(
              context,
              title: "Govt. Officer",
              icon: Icons.admin_panel_settings,
              color: Colors.blue.shade800,
              onTap: () => _navigateToLogin(context, "officer"),
            ),

            const SizedBox(height: 20),

            // 3. NGO / Social Worker Card
            _buildRoleCard(
              context,
              title: "NGO / Social Worker",
              icon: Icons.volunteer_activism,
              color: Colors.orange.shade800,
              onTap: () => _navigateToLogin(context, "ngo"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(userRole: role)),
    );
  }
}