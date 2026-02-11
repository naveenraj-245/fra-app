import 'package:flutter/material.dart';

class HelpCentersScreen extends StatelessWidget {
  const HelpCentersScreen({super.key});

  final List<Map<String, String>> centers = const [
    {
      "name": "VanAdhikar Seva Kendra",
      "address": "12, Market Road, Nilgiris",
      "phone": "+91 98765 43210",
      "type": "NGO"
    },
    {
      "name": "District Legal Aid Clinic",
      "address": "Room 4, District Court Complex",
      "phone": "0423 244 1234",
      "type": "Legal Aid"
    },
    {
      "name": "Tribal Welfare Office",
      "address": "Collectorate Main Building",
      "phone": "0423 255 5678",
      "type": "Govt. Office"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Help Centers"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: centers.length,
        itemBuilder: (context, index) {
          final center = centers[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.brown.withValues(alpha: 0.1),
                child: const Icon(Icons.business, color: Colors.brown),
              ),
              title: Text(center['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(center['address']!, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(center['type']!, style: const TextStyle(fontSize: 10, color: Colors.brown, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () {
                   // Logic to launch phone dialer
                   // launchUrl(Uri.parse("tel:${center['phone']}"));
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Calling ${center['phone']}...")));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
