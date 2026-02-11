import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20), // Forest Green
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All notifications marked as read")),
              );
            },
            tooltip: "Mark all as read",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- SECTION: NEW ALERTS ---
          const Text(
            "New", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          
          _buildAlertCard(
            title: "Field Verification Scheduled",
            message: "Forest Officer Mr. Rao will visit your plot (Survey No. 45/B) tomorrow at 10:00 AM.",
            time: "2 hours ago",
            type: AlertType.urgent,
          ),

          _buildAlertCard(
            title: "Document Missing",
            message: "Please upload your Voter ID card to complete the claim application.",
            time: "5 hours ago",
            type: AlertType.warning,
          ),

          const SizedBox(height: 25),

          // --- SECTION: EARLIER ALERTS ---
          const Text(
            "Earlier", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          _buildAlertCard(
            title: "Gram Sabha Meeting",
            message: "Community meeting regarding community forest rights (CFR) at the Village Hall.",
            time: "Yesterday, 4:00 PM",
            type: AlertType.info,
          ),

          _buildAlertCard(
            title: "Claim Submitted Successfully",
            message: "Your application ID #FRA-2026-889 has been received by the SDLC.",
            time: "Feb 08, 2026",
            type: AlertType.success,
          ),
          
          _buildAlertCard(
            title: "App Update Available",
            message: "New features added for offline map support. Update now.",
            time: "Feb 01, 2026",
            type: AlertType.info,
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildAlertCard({
    required String title,
    required String message,
    required String time,
    required AlertType type,
  }) {
    // Determine Color and Icon based on type
    Color color;
    IconData icon;
    
    switch (type) {
      case AlertType.urgent:
        color = Colors.red;
        icon = Icons.notification_important;
        break;
      case AlertType.warning:
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case AlertType.success:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case AlertType.info:
        color = Colors.blue;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Make it clickable if needed
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICON CONTAINER
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                
                // TEXT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          if (type == AlertType.urgent)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 8, height: 8,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message, 
                        style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        time, 
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Simple Enum to manage alert styles
enum AlertType { urgent, warning, info, success }
