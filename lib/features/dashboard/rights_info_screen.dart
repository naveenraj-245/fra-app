import 'package:flutter/material.dart';
import '../chat/ai_chat_screen.dart'; // Links to your Gemini AI

class RightsInfoScreen extends StatelessWidget {
  const RightsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light green background
      appBar: AppBar(
        title: const Text("Know Your Rights"),
        backgroundColor: const Color(0xFF1B5E20), // Forest Green
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.menu_book, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Forest Rights Act, 2006", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Protecting your land and heritage.", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Text("Frequently Asked Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(height: 16),

            // Info Cards (Expandable)
            _buildInfoCard(
              icon: Icons.info_outline,
              title: "What is the FRA?",
              content: "The Forest Rights Act (FRA) recognizes the rights of forest-dwelling tribal communities and other traditional forest dwellers to forest resources, on which these communities were dependent for a variety of needs, including livelihood, habitation, and other socio-cultural needs."
            ),
            
            _buildInfoCard(
              icon: Icons.people_alt,
              title: "Who can apply?",
              content: "1. Forest Dwelling Scheduled Tribes (FDST) who primarily reside in and depend on the forests.\n\n2. Other Traditional Forest Dwellers (OTFD) who have lived in the forest for at least three generations (75 years) prior to December 13, 2005."
            ),

            _buildInfoCard(
              icon: Icons.landscape,
              title: "Types of Rights",
              content: "• Individual Forest Rights (IFR): Right to live in and cultivate forest land (up to 4 hectares).\n\n• Community Forest Rights (CFR): Right to protect, regenerate, or conserve any community forest resource."
            ),

            _buildInfoCard(
              icon: Icons.folder_special,
              title: "Documents Needed",
              content: "To prove your claim, you need at least two of the following:\n\n• Voter ID or Ration Card\n• Caste Certificate\n• Extracts from government records\n• Statement from village elders\n• Gram Sabha resolution"
            ),

            const SizedBox(height: 30),

            // AI Help Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.smart_toy, size: 40, color: Color(0xFF1B5E20)),
                  const SizedBox(height: 12),
                  const Text("Have more questions?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Chat with our AI Assistant in your local language.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Ask VanAdhikar AI"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER FOR EXPANDABLE CARDS ---
  Widget _buildInfoCard({required IconData icon, required String title, required String content}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF1B5E20)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        children: [
          Text(content, style: const TextStyle(color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }
}