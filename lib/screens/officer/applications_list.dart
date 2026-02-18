import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'application_details.dart';

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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Text("Applications Review"),
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
          _buildLiveList("Pending"),
          _buildLiveList("Approved"),
          _buildLiveList("Rejected"),
        ],
      ),
    );
  }

  // --- LIVE FIREBASE LIST ---
  Widget _buildLiveList(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('claims')
          .where('status', isEqualTo: statusFilter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

        final claims = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: claims.length,
          itemBuilder: (context, index) {
            final doc = claims[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildClaimCard(context, data);
          },
        );
      },
    );
  }

  // --- CARD DESIGN ---
  // --- CARD DESIGN ---
  Widget _buildClaimCard(BuildContext context, Map<String, dynamic> claim) {
    String status = claim['status'] ?? "Pending";
    String name = claim['applicantName']?.toString().trim() ?? ""; // Safely handle nulls
    
    // ✅ Fix: Only grab the first letter if the name actually exists
    String initial = name.isNotEmpty ? name[0].toUpperCase() : "?"; 
    
    // Provide a fallback name for the UI if it's empty
    String displayString = name.isNotEmpty ? name : "Unknown Applicant";
    
    String type = claim['type'] ?? "Land Claim";
    String id = claim['id'] ?? "Unknown ID";
    
    // Safely format date
    String date = "Recently";
    if (claim['submittedAt'] != null && claim['submittedAt'] is Timestamp) {
      date = (claim['submittedAt'] as Timestamp).toDate().toString().substring(0, 10);
    }

    Color statusColor = status == "Approved" ? Colors.green : (status == "Rejected" ? Colors.red : Colors.orange);
    IconData statusIcon = status == "Approved" ? Icons.check_circle : (status == "Rejected" ? Icons.cancel : Icons.hourglass_top);

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
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      // ✅ Use the safe initial here
                      child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Use the safe display string here
                        Text(displayString, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
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
                    Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Applied On", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(date, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplicationDetailsScreen(claimData: claim),
                    ),
                  );
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