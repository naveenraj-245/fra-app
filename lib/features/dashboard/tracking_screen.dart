import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        title: const Text("Track Application"),
        backgroundColor: const Color(0xFF1B5E20), // Forest Green
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Please login to track claims."))
          : StreamBuilder<QuerySnapshot>(
              // 1. QUERY: Get claims for THIS user, sorted by newest first
              stream: FirebaseFirestore.instance
                  .collection('claims')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('submittedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // --- LOADING STATE ---
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // --- ERROR STATE ---
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                // --- EMPTY STATE ---
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.folder_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No active applications found."),
                        SizedBox(height: 5),
                        Text("Submit a new claim to see it here.", 
                             style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                }

                // --- DATA EXISTS: Show the latest claim ---
                final doc = snapshot.data!.docs.first;
                final data = doc.data() as Map<String, dynamic>;
                
                // Extract Fields
                String status = (data['status'] ?? 'submitted').toString().toLowerCase();
                Timestamp? ts = data['submittedAt'];
                String dateStr = ts != null 
                    ? DateFormat('MMM dd, yyyy').format(ts.toDate()) 
                    : "Just now";
                String appId = doc.id.substring(0, 6).toUpperCase();

                // Extract AI Data (from Python Backend)
                Map<String, dynamic>? aiData = data['aiVerification'] as Map<String, dynamic>?;
                String aiNote = aiData?['note'] ?? "Satellite analysis in progress...";
                double? aiScore = aiData?['score'];

                // Determine Timeline Stage
                int currentStage = 1; 
                if (status == 'review') currentStage = 3;   // AI Flagged / Review
                if (status == 'approved') currentStage = 4; // AI Approved
                if (status == 'rejected') currentStage = 4; // Finalized

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. APPLICATION ID CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05), 
                              blurRadius: 8, 
                              offset: const Offset(0, 2)
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Application ID", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("#FRA-2026-$appId", 
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Submission Date:", style: TextStyle(fontSize: 14, color: Colors.black54)),
                                Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text("Live Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // 2. TIMELINE STEPS
                      _buildTimelineStep(
                        title: "Application Submitted",
                        subtitle: "Form received by Gram Sabha.",
                        date: dateStr,
                        state: _StepState.completed,
                        isFirst: true,
                      ),

                      _buildTimelineStep(
                        title: "Satellite Verification (AI)",
                        subtitle: aiScore != null 
                            ? "Analysis Complete (NDVI: ${aiScore.toStringAsFixed(2)})"
                            : "Checking 2005 Landsat imagery...",
                        date: aiScore != null ? "Done" : "Processing...",
                        state: aiScore != null ? _StepState.completed : _StepState.active,
                        icon: Icons.satellite_alt,
                      ),

                      _buildTimelineStep(
                        title: "Official Review (SDLC)",
                        subtitle: status == 'review' 
                            ? "Flagged for manual check." 
                            : "Standard procedural review.",
                        date: status == 'review' ? "Action Needed" : "Pending",
                        state: _getStepState(3, currentStage),
                        icon: Icons.assignment_late_outlined,
                      ),

                      _buildTimelineStep(
                        title: "Final Approval (DLC)",
                        subtitle: "Issuance of Title Deed (Patta).",
                        date: status == 'approved' ? "Approved" : "Pending",
                        state: _getStepState(4, currentStage),
                        isLast: true,
                      ),

                      const SizedBox(height: 24),

                      // 3. AI INFO BOX (Dynamic Content)
                      if (aiData != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: status == 'review' ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: status == 'review' ? Colors.orange : Colors.blue.withValues(alpha: 0.3)
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                status == 'review' ? Icons.warning_amber : Icons.info_outline, 
                                color: status == 'review' ? Colors.orange[800] : Colors.blue, 
                                size: 24
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "AI Analysis Report:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: status == 'review' ? Colors.orange[900] : Colors.blue[900]
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      aiNote,
                                      style: TextStyle(
                                        color: status == 'review' ? Colors.orange[900] : Colors.black87, 
                                        fontSize: 13, 
                                        height: 1.4
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // --- Helpers ---

  _StepState _getStepState(int stepIndex, int currentStage) {
    if (currentStage > stepIndex) return _StepState.completed;
    if (currentStage == stepIndex) return _StepState.active;
    return _StepState.pending;
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String date,
    required _StepState state,
    IconData? icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    Color color;
    IconData stepIcon;
    Color iconColor = Colors.white;

    switch (state) {
      case _StepState.completed:
        color = Colors.green;
        stepIcon = Icons.check;
        break;
      case _StepState.active:
        color = Colors.orange;
        stepIcon = icon ?? Icons.sync; 
        break;
      case _StepState.pending:
        color = Colors.grey.shade300;
        stepIcon = Icons.circle_outlined; 
        iconColor = Colors.grey;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: state == _StepState.pending ? Colors.grey.shade200 : color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(stepIcon, size: 18, color: iconColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: state == _StepState.completed ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, 
                          color: state == _StepState.active ? Colors.orange[800] : Colors.black87)),
                      Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { completed, active, pending }
