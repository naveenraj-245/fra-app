import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// 1. THE MODEL (Data Structure)
// ==========================================
class GrievanceModel {
  final String? id;
  final String userId;
  final String type;
  final String description;
  final String status;
  final DateTime submittedAt;

  GrievanceModel({
    this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.status,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'description': description,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }
}

// ==========================================
// 2. THE SERVICE (Database Logic)
// ==========================================
class GrievanceService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('grievances');

  Future<void> addGrievance(GrievanceModel grievance) async {
    await _collection.add(grievance.toMap());
  }
}

// ==========================================
// 3. THE SCREEN (UI)
// ==========================================
class GrievanceScreen extends StatefulWidget {
  const GrievanceScreen({super.key});

  @override
  State<GrievanceScreen> createState() => _GrievanceScreenState();
}

class _GrievanceScreenState extends State<GrievanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _grievanceService = GrievanceService(); // Uses the class above
  
  bool _isLoading = false;
  String _selectedType = 'Land Dispute';

  final List<String> _grievanceTypes = [
    'Land Dispute',
    'Boundary Issue',
    'Harassment by Officials',
    'Crop Damage',
    'Illegal Fencing',
    'Other'
  ];

  Future<void> _submitGrievance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("You must be logged in to file a grievance.");
      }

      final newGrievance = GrievanceModel(
        userId: user.uid,
        type: _selectedType,
        description: _descController.text.trim(),
        status: 'Pending',
        submittedAt: DateTime.now(),
      );

      await _grievanceService.addGrievance(newGrievance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Grievance submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File a Grievance"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Issue Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: _grievanceTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              const Text("Describe the Issue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "Enter details here...",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Please enter a description" : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  onPressed: _isLoading ? null : _submitGrievance,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Submit Report"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}