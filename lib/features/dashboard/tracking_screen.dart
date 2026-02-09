import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Track Application"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: Text("Please login to track your application"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('claims')
                  .where('userId', isEqualTo: userId)
                  .orderBy('submittedAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No active applications found."));
                }

                final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final docId = snapshot.data!.docs.first.id;
                
                String status = (data['status'] ?? 'submitted').toString().toLowerCase();
                
                Timestamp? ts = data['submittedAt'];
                String formattedDate = ts != null 
                    ? DateFormat('MMM dd, yyyy').format(ts.toDate()) 
                    : "Recently";

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Application ID", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text("#FRA-2026-${docId.substring(0, 5).toUpperCase()}", 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Submission Date:", style: TextStyle(fontSize: 14)),
                                Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      const Text("Live Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      _buildTimelineStep(
                        title: "Application Submitted",
                        subtitle: "Form received by the Gram Sabha.",
                        date: formattedDate,
                        icon: Icons.description,
                        color: Colors.green,
                        isCompleted: true,
                      ),
                      
                      _buildTimelineStep(
                        title: "Gram Sabha Verification",
                        subtitle: "Field survey and boundary check done.",
                        date: status == "submitted" ? "Pending" : "Completed",
                        icon: Icons.how_to_reg,
                        color: Colors.green,
                        isCompleted: status != "submitted",
                        isActive: status == "submitted",
                      ),
                      
                      _buildTimelineStep(
                        title: "SDLC Review",
                        subtitle: "Sub-Divisional Level Committee is reviewing.",
                        date: status == "review" ? "In Progress" : (status == "approved" ? "Done" : "Pending"),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                        isCompleted: status == "approved",
                        isActive: status == "review",
                      ),
                      
                      _buildTimelineStep(
                        title: "DLC Final Approval",
                        subtitle: "Issuance of the final title certificate.",
                        date: status == "approved" ? "Approved" : "Pending",
                        icon: Icons.verified_user,
                        color: Colors.green,
                        isCompleted: status == "approved",
                        isLast: true,
                      ),

                      const SizedBox(height: 20),
                      _buildInfoBox(status),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoBox(String status) {
    String msg = "Your application is currently being processed. You will be notified of any updates.";
    if (status == "submitted") msg = "Gram Sabha is organizing a field survey for your land.";
    if (status == "review") msg = "SDLC review usually takes 7-10 working days.";
    if (status == "approved") msg = "Congratulations! Your title certificate is ready for download.";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required Color color,
    bool isCompleted = false,
    bool isActive = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted || isActive ? color : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCompleted || isActive ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isCompleted || isActive ? Colors.black54 : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? color : Colors.grey,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}