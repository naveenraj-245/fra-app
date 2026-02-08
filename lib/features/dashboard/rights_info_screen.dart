import 'package:flutter/material.dart';

class RightsInfoScreen extends StatelessWidget {
  const RightsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Know Your Rights"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Introductory Text
          _buildHeroSection(),
          const SizedBox(height: 20),

          // Core Rights Cards
          _buildRightCard("Forest Land Rights", "Rights to cultivate and reside on forest land occupied before December 13, 2005", Icons.forest, Colors.green),
          _buildRightCard("Community Rights", "Rights to community resources including water bodies, grazing areas, and traditional access routes", Icons.home, Colors.blue),
          _buildRightCard("Minor Forest Produce", "Rights to collect, use, and sell minor forest produce traditionally gathered by forest dwellers", Icons.eco, Colors.teal),
          _buildRightCard("Rehabilitation Rights", "Rights to rehabilitation in case of illegal eviction or forced displacement from traditional lands", Icons.shield, Colors.orange),

          const SizedBox(height: 24),

          // Eligibility and Documents
          _buildListSection("Eligibility Criteria", [
            "Members of Scheduled Tribes who primarily reside in forests",
            "Traditional forest dwellers who have resided in forest land for at least three generations (75 years)",
            "Must have been residing in the forest land on or before December 13, 2005",
            "Dependence on forest land for bonafide livelihood needs"
          ], Icons.check_circle_outline, Colors.green),

          const SizedBox(height: 16),

          _buildListSection("Documents Required", [
            "Proof of residence (ration card, voter ID, or any government document)",
            "Evidence of occupation before December 13, 2005",
            "Tribal certificate (for ST claimants)",
            "Land survey documents or maps"
          ], Icons.description_outlined, Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("About the Forest Rights Act", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF311B92))),
          SizedBox(height: 8),
          Text(
            "The Scheduled Tribes and Other Traditional Forest Dwellers (Recognition of Forest Rights) Act, 2006 recognizes and vests the forest rights and occupation in forest land in forest dwelling Scheduled Tribes and other traditional forest dwellers who have been residing in such forests for generations.",
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildRightCard(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.volume_up, color: Colors.grey, size: 20), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Icon(Icons.volume_up, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.black87))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}