import 'dart:convert'; 
import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("My Digital Locker"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Permanent Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Upload your proofs here once. They will be automatically attached to your future claims.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Document 1: Voter ID
              _buildDocumentTile(
                title: "Voter ID / Aadhaar",
                dbKey: "voterId",
                uploadedFileName: userData['voterId_name'],
                base64Data: userData['voterId_base64'], 
              ),

              // Document 2: Ration Card
              _buildDocumentTile(
                title: "Ration Card",
                dbKey: "rationCard",
                uploadedFileName: userData['rationCard_name'],
                base64Data: userData['rationCard_base64'],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocumentTile({required String title, required String dbKey, String? uploadedFileName, String? base64Data}) {
    bool isUploaded = uploadedFileName != null && base64Data != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isUploaded ? Colors.green[50] : Colors.orange[50],
          child: Icon(
            isUploaded ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isUploaded ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isUploaded ? "File: $uploadedFileName" : "Missing Document"),
        trailing: isUploaded
            ? OutlinedButton.icon(
                onPressed: () => _viewDocument(uploadedFileName, base64Data),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text("View"),
              )
            : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _pickAndUploadDocument(dbKey),
                icon: const Icon(Icons.upload, size: 16),
                label: const Text("Upload"),
              ),
      ),
    );
  }

  void _pickAndUploadDocument(String dbKey) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, 
      withData: true, 
    );

    if (result == null || result.files.single.bytes == null) return;

    String fileName = result.files.single.name;
    Uint8List imageBytes = result.files.single.bytes!; 

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFF1B5E20)),
            SizedBox(width: 20),
            Expanded(child: Text("Converting and saving securely...")),
          ],
        ),
      ),
    );

    try {
      String base64Image = base64Encode(imageBytes);

      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        '${dbKey}_name': fileName,
        '${dbKey}_base64': base64Image,
        '${dbKey}_timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$fileName saved securely!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _viewDocument(String fileName, String base64Data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(fileName, style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          height: 300,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(base64Data),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Close", style: TextStyle(color: Color(0xFF1B5E20)))
          ),
        ],
      ),
    );
  }
}