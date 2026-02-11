import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ IMPORT IS CRITICAL
import '../../services/database_service.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> claimData;

  const ApplicationDetailsScreen({super.key, required this.claimData});

  // ✅ HELPER: Safely convert Timestamp to String
  String _formatDate(dynamic submittedAt) {
    if (submittedAt == null) return "Recently";
    try {
      if (submittedAt is Timestamp) {
        // Convert Firestore Timestamp to DateTime
        return submittedAt.toDate().toString().substring(0, 10);
      } else if (submittedAt is String) {
        // If it's already a string, return it
        return submittedAt;
      }
      return "Unknown Date";
    } catch (e) {
      return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    // Safe Data Extraction
    final String claimId = claimData['id'] ?? "Unknown ID";
    final String name = claimData['applicantName'] ?? "Unknown Applicant";
    final String status = claimData['status'] ?? "Pending";
    
    // ✅ USE THE HELPER HERE
    final String date = _formatDate(claimData['submittedAt']);
    
    final String type = claimData['type'] ?? "Individual Land";
    final String area = claimData['area'] ?? "N/A";
    
    // Handle Coordinates safely
    String coordinates = "No GPS Data";
    if (claimData['location'] != null && claimData['location'] is GeoPoint) {
      GeoPoint loc = claimData['location'];
      coordinates = "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Claim #$claimId"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER SECTION
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.person, size: 35, color: Color(0xFF0D47A1)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Applied on: $date",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 40),

            // 2. CLAIM DETAILS
            _buildSectionTitle("Land Details"),
            _buildDetailRow(Icons.landscape, "Claim Type", type),
            _buildDetailRow(Icons.straighten, "Estimated Area", "$area Acres"),
            _buildDetailRow(Icons.location_on, "GPS Coordinates", coordinates),
            _buildDetailRow(Icons.phone, "Contact", claimData['phone'] ?? "N/A"),
            
            if (claimData['isAssisted'] == true)
              _buildDetailRow(Icons.assignment_ind, "Assisted By", "Officer (You)"),

            const SizedBox(height: 24),

            // 3. EVIDENCE SECTION
            _buildSectionTitle("Submitted Evidence"),
            const SizedBox(height: 10),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text("Site Photograph.jpg", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // 4. ACTION BUTTONS
            if (status == "Pending") ...[
              const Text("Officer Decision", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDecision(context, dbService, claimId, "Rejected"),
                      icon: const Icon(Icons.close),
                      label: const Text("REJECT"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleDecision(context, dbService, claimId, "Approved"),
                      icon: const Icon(Icons.check),
                      label: const Text("APPROVE"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // If already decided
               Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getStatusColor(status)),
                ),
                child: Text(
                  "This claim has been $status",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- HELPER FUNCTIONS ---
  Color _getStatusColor(String status) {
    if (status == 'Approved') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _handleDecision(BuildContext context, DatabaseService db, String id, String status) {
     db.updateClaimStatus(id, status).then((_) {
       if (context.mounted) {
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Claim $status")));
       }
     });
  }
}