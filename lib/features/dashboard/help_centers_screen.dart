import 'package:flutter/material.dart';

class HelpCentersScreen extends StatelessWidget {
  const HelpCentersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for hackathon presentation
    final List<Map<String, dynamic>> helpCenters = [
      {
        "name": "Tribal Welfare Office",
        "type": "Govt Help Desk",
        "address": "Collectorate Campus, Ooty, Nilgiris",
        "distance": "4.2 km",
        "phone": "+91 80000 11111",
        "isOpen": true,
      },
      {
        "name": "VanAdhikar NGO Support",
        "type": "NGO Partner",
        "address": "Main Bazar Road, Gudalur",
        "distance": "12.5 km",
        "phone": "+91 90000 22222",
        "isOpen": true,
      },
      {
        "name": "Gram Sabha Center",
        "type": "Community Center",
        "address": "Panchayat Office, Kotagiri",
        "distance": "18.0 km",
        "phone": "+91 70000 33333",
        "isOpen": false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), 
      appBar: AppBar(
        title: const Text("Nearby Help Centers"),
        backgroundColor: const Color(0xFF1B5E20), 
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: helpCenters.length,
        itemBuilder: (context, index) {
          final center = helpCenters[index];
          return _buildCenterCard(context, center);
        },
      ),
    );
  }

  Widget _buildCenterCard(BuildContext context, Map<String, dynamic> center) {
    bool isOpen = center['isOpen'];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    center['type'],
                    style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(center['distance'], style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(center['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(center['address'], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOpen ? "Open Now" : "Closed",
                  style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Calling ${center['name']}...")),
                      );
                    },
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("Call"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E20),
                      side: const BorderSide(color: Color(0xFF1B5E20)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Opening Maps...")),
                      );
                    },
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text("Directions"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}