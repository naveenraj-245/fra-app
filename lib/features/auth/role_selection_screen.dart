import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../language_provider.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the translation helper
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Modern light background
      appBar: AppBar(
        title: const Text("Satya-Setu", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20), // Forest Green Theme
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.language),
              tooltip: "Change Language",
              onPressed: () => _showLanguagePicker(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Welcome Header
              Text(
                lang.translate('who_are_you'),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                lang.translate('select_role'),
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // 1. DWELLER CARD (Green)
              _buildRoleCard(
                context,
                title: lang.translate('dweller'),
                subtitle: "Apply for land rights and track status",
                icon: Icons.nature_people,
                color: const Color(0xFF1B5E20), // Forest Green
                onTap: () => _navigateToLogin(context, "dweller"),
              ),
              
              const SizedBox(height: 16),

              // 2. OFFICER CARD (Navy Blue)
              _buildRoleCard(
                context,
                title: lang.translate('officer'),
                subtitle: "Verify claims and manage approvals",
                icon: Icons.admin_panel_settings,
                color: const Color(0xFF0D47A1), // Navy Blue
                onTap: () => _navigateToLogin(context, "officer"),
              ),

              const SizedBox(height: 16),

              // 3. NGO CARD (Teal)
              _buildRoleCard(
                context,
                title: lang.translate('ngo'),
                subtitle: "Assist dwellers with applications",
                icon: Icons.handshake,
                color: const Color(0xFF00695C), // Deep Teal
                onTap: () => _navigateToLogin(context, "ngo"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LANGUAGE PICKER ---
  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final lp = Provider.of<LanguageProvider>(context, listen: false);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Language", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                title: const Text("English", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () { lp.changeLanguage('en'); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                title: const Text("தமிழ் (Tamil)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () { lp.changeLanguage('ta'); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                title: const Text("हिन्दी (Hindi)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                onTap: () { lp.changeLanguage('hi'); Navigator.pop(context); },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- REUSABLE ROLE CARD WITH SUBTITLE ---
  Widget _buildRoleCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 36, color: color),
                ),
                const SizedBox(width: 20),
                
                // Text Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.3),
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- NAVIGATION ---
  void _navigateToLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(userRole: role)),
    );
  }
}