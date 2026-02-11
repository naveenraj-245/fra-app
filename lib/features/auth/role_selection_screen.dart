import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../language_provider.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Access the translation helper
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Satya-Shield"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          // 2. Updated Language Button
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _showLanguagePicker(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              lang.translate('who_are_you'), // Translated
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              lang.translate('select_role'), // Translated
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            _buildRoleCard(
              context,
              title: lang.translate('dweller'), // Translated
              icon: Icons.person_pin_circle,
              color: Colors.green.shade700,
              onTap: () => _navigateToLogin(context, "dweller"),
            ),
            
            const SizedBox(height: 20),

            _buildRoleCard(
              context,
              title: lang.translate('officer'), // Translated
              icon: Icons.admin_panel_settings,
              color: Colors.blue.shade800,
              onTap: () => _navigateToLogin(context, "officer"),
            ),

            const SizedBox(height: 20),

            _buildRoleCard(
              context,
              title: lang.translate('ngo'), // Translated
              icon: Icons.volunteer_activism,
              color: Colors.orange.shade800,
              onTap: () => _navigateToLogin(context, "ngo"),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Language Picker Logic
  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final lp = Provider.of<LanguageProvider>(context, listen: false);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Language", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ListTile(
                title: const Text("English"),
                onTap: () { lp.changeLanguage('en'); Navigator.pop(context); },
              ),
              ListTile(
                title: const Text("தமிழ் (Tamil)"),
                onTap: () { lp.changeLanguage('ta'); Navigator.pop(context); },
              ),
              ListTile(
                title: const Text("हिन्दी (Hindi)"),
                onTap: () { lp.changeLanguage('hi'); Navigator.pop(context); },
              ),
            ],
          ),
        );
      },
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
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
