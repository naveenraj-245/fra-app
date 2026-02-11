import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: AdminDashboard(), debugShowCheckedModeBanner: false));
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("FRA Officer Portal - District Review"),
        backgroundColor: const Color(0xFF0F172A), // Slate 900
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pending Claims for Verification", 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('claims').orderBy('submittedAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      return _buildClaimRow(context, docId, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimRow(BuildContext context, String docId, Map<String, dynamic> data) {
    String name = data['beneficiary']?['fullName'] ?? "Unknown";
    double ndvi = (data['aiVerification']?['score'] ?? 0.0).toDouble();
    String status = data['status'] ?? 'submitted';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("AI NDVI Score (2005): ${ndvi.toStringAsFixed(3)}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(status),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _inspectClaim(context, docId, name, ndvi),
              child: const Text("Inspect"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (status == 'approved') color = Colors.green;
    if (status == 'review') color = Colors.orange;
    if (status == 'rejected') color = Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _inspectClaim(BuildContext context, String docId, String name, double score) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Verify Claim: $name"),
        content: Text("AI analyzed 2005 Landsat imagery and found an NDVI of $score.\n\nDo you want to issue the official Title Deed?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              FirebaseFirestore.instance.collection('claims').doc(docId).update({'status': 'approved'});
              Navigator.pop(ctx);
            }, 
            child: const Text("APPROVE"),
          ),
        ],
      ),
    );
  }
}
