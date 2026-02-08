import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Track Application"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Application Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Application ID", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Text("#FRA-2026-SKY-01", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Submission Date:", style: TextStyle(fontSize: 14)),
                      Text("Feb 02, 2026", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("Live Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Timeline Steps for the 3-Tier Approval Process
            _buildTimelineStep(
              title: "Application Submitted",
              subtitle: "Form received by the Gram Sabha.",
              date: "Feb 02",
              icon: Icons.description,
              color: Colors.green,
              isCompleted: true,
            ),
            _buildTimelineStep(
              title: "Gram Sabha Verification",
              subtitle: "Field survey and boundary check done.",
              date: "Feb 05",
              icon: Icons.how_to_reg,
              color: Colors.green,
              isCompleted: true,
            ),
            _buildTimelineStep(
              title: "SDLC Review",
              subtitle: "Sub-Divisional Level Committee is reviewing.",
              date: "In Progress",
              icon: Icons.pending_actions,
              color: Colors.orange,
              isCompleted: false,
              isActive: true,
            ),
            _buildTimelineStep(
              title: "DLC Final Approval",
              subtitle: "Issuance of the final title certificate.",
              date: "Pending",
              icon: Icons.verified_user,
              color: Colors.grey,
              isCompleted: false,
              isLast: true,
            ),

            const SizedBox(height: 20),
            
            // Helpful Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "SDLC review usually takes 7-10 working days. You will be notified of any updates.",
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDER FOR THE TIMELINE ---
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
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isCompleted || isActive ? color : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  size: 16,
                  color: isCompleted || isActive ? Colors.white : Colors.grey,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? color : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 15, 
                        color: isActive ? color : Colors.black
                      )),
                      Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}