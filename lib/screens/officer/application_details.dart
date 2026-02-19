import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> claimData;
  final String claimId; 

  const ApplicationDetailsScreen({super.key, required this.claimData, required this.claimId});

  @override
  State<ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Safely extract the userId and current status
    final String userId = widget.claimData['userId']?.toString().trim() ?? '';
    final String currentStatus = widget.claimData['status'] ?? 'Pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Claim"),
        backgroundColor: const Color(0xFF0D47A1), // Officer Navy Blue
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CLAIM DETAILS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Applicant Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                    // Small status badge at the top
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(currentStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        currentStatus, 
                        style: TextStyle(color: _getStatusColor(currentStatus), fontWeight: FontWeight.bold, fontSize: 12)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow("Name", widget.claimData['applicantName'] ?? "N/A"),
                        const Divider(),
                        _buildInfoRow("Age", widget.claimData['age'] ?? "N/A"),
                        const Divider(),
                        _buildInfoRow("Village", widget.claimData['village'] ?? "N/A"),
                        const Divider(),
                        _buildInfoRow("Community", widget.claimData['communityType'] ?? "N/A"),
                        const Divider(),
                        _buildInfoRow("Area Claimed", "${widget.claimData['areaClaimed'] ?? '0'} Hectares"),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // 2. FETCH AND SHOW SECURE DOCUMENTS
                const Text("Verification Documents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                const SizedBox(height: 12),
                
                if (userId.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      "Warning: This is an older test claim without a User ID. No digital documents are attached.", 
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                    ),
                  )
                else
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text("No secure documents found for this user in the Digital Locker.", style: TextStyle(color: Colors.orange));
                      }

                      var userData = snapshot.data!.data() as Map<String, dynamic>;

                      return Column(
                        children: [
                          _buildDocumentViewer("Voter ID / Aadhaar", userData['voterId_base64']),
                          const SizedBox(height: 16),
                          _buildDocumentViewer("Ration Card", userData['rationCard_base64']),
                        ],
                      );
                    },
                  ),
                
                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),

          // 3. DYNAMIC BOTTOM ACTION BAR
          if (!_isProcessing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                // ✅ THE FIX: Only show buttons if Pending. Otherwise show a read-only banner.
                child: currentStatus == 'Pending' 
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)),
                            onPressed: () => _updateStatus("Rejected"),
                            icon: const Icon(Icons.cancel),
                            label: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                            onPressed: () => _updateStatus("Approved"),
                            icon: const Icon(Icons.check_circle),
                            label: const Text("Approve", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(currentStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(
                        "This claim has been $currentStatus",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: _getStatusColor(currentStatus),
                          fontSize: 16
                        ),
                      ),
                    ),
              ),
            ),
            
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---

  Color _getStatusColor(String status) {
    if (status == 'Approved') return Colors.green;
    if (status == 'Rejected') return Colors.red;
    return Colors.orange;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDocumentViewer(String title, String? base64Data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.blue[50],
        iconColor: const Color(0xFF0D47A1),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(base64Data != null ? "Document Attached" : "Missing Document", style: TextStyle(color: base64Data != null ? Colors.green : Colors.red)),
        children: [
          if (base64Data != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(base64Data),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text("Error loading image format."),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("The applicant did not upload this document."),
            )
        ],
      ),
    );
  }

  // --- DATABASE UPDATE ---

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isProcessing = true);
    
    try {
      await FirebaseFirestore.instance.collection('claims').doc(widget.claimId).update({
        'status': newStatus,
      });

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Claim has been $newStatus!"), backgroundColor: newStatus == "Approved" ? Colors.green : Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}