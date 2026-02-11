import 'package:flutter/material.dart';

class ApplicationsListScreen extends StatefulWidget {
  const ApplicationsListScreen({super.key});

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Text("Applications"),
        backgroundColor: const Color(0xFF0D47A1), // Navy Blue
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(statusFilter: "Pending"),
          _buildList(statusFilter: "Approved"),
          _buildList(statusFilter: "Rejected"),
        ],
      ),
    );
  }

  // --- BUILD THE LIST OF CLAIMS ---
  Widget _buildList({required String statusFilter}) {
    // Mock Data - In real app, this comes from Firebase
    final List<Map<String, String>> allClaims = [
      {"name": "Ravi Kumar", "id": "CLM-2026-001", "type": "Individual Land", "status": "Pending", "date": "10 Feb 2026"},
      {"name": "Irula Village Council", "id": "CLM-2026-002", "type": "Community Rights", "status": "Approved", "date": "05 Feb 2026"},
      {"name": "Sita Devi", "id": "CLM-2026-003", "type": "Forest Produce", "status": "Pending", "date": "11 Feb 2026"},
      {"name": "Muthu Vel", "id": "CLM-2026-004", "type": "Individual Land", "status": "Rejected", "date": "01 Jan 2026"},
    ];

    // Filter Logic
    final filteredList = allClaims.where((claim) => claim['status'] == statusFilter).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text("No $statusFilter Applications", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final claim = filteredList[index];
        return _buildClaimCard(claim);
      },
    );
  }

  // --- CARD DESIGN ---
  Widget _buildClaimCard(Map<String, String> claim) {
    Color statusColor;
    IconData statusIcon;

    switch (claim['status']) {
      case "Approved":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "Rejected":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_top;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar & Name
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Text(claim['name']![0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(claim['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(claim['id']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(claim['status']!, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Claim Type", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(claim['type']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Applied On", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(claim['date']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Details Page
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening Application Details...")));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("View Details & Take Action"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}