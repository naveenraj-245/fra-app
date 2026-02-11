import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

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
  final String? imageUrl;       // New: URL of the uploaded image
  final Map<String, double>? location; // New: Lat/Lng

  GrievanceModel({
    this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.status,
    required this.submittedAt,
    this.imageUrl,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'description': description,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'imageUrl': imageUrl,
      'location': location,
    };
  }
}

// ==========================================
// 2. THE SERVICE (Database & Storage Logic)
// ==========================================
class GrievanceService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('grievances');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      String fileName = 'grievances/${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // Image upload failed: $e
      return null;
    }
  }

  // Save data to Firestore
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
  final _grievanceService = GrievanceService();
  
  bool _isLoading = false;
  String _selectedType = 'Land Dispute';
  File? _imageFile;
  Position? _currentPosition;
  final ImagePicker _picker = ImagePicker();

  final List<String> _grievanceTypes = [
    'Land Dispute',
    'Boundary Issue',
    'Harassment by Officials',
    'Crop Damage',
    'Illegal Fencing',
    'Other'
  ];

  // --- Image Picker Logic ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // --- Location Logic ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    setState(() => _isLoading = true);
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });
  }

  // --- Submission Logic ---
  Future<void> _submitGrievance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("You must be logged in.");

      // 1. Upload Image if exists
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _grievanceService.uploadImage(_imageFile!, user.uid);
      }

      // 2. Prepare Data
      final newGrievance = GrievanceModel(
        userId: user.uid,
        type: _selectedType,
        description: _descController.text.trim(),
        status: 'Pending',
        submittedAt: DateTime.now(),
        imageUrl: imageUrl,
        location: _currentPosition != null 
            ? {'lat': _currentPosition!.latitude, 'lng': _currentPosition!.longitude} 
            : null,
      );

      // 3. Save to Firestore
      await _grievanceService.addGrievance(newGrievance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report submitted successfully!"), backgroundColor: Colors.green),
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
              // --- Issue Type ---
              const Text("Select Issue Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: _grievanceTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              
              const SizedBox(height: 24),

              // --- Description ---
              const Text("Describe the Issue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Enter details here...",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Please enter a description" : null,
              ),

              const SizedBox(height: 24),

              // --- Evidence (Image) ---
              const Text("Attach Evidence", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageFile == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Tap to take a photo", style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Location ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: Text(_currentPosition == null ? "Get GPS" : "Updated"),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
              ),
              if (_currentPosition != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}",
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 32),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading ? null : _submitGrievance,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Submit Report", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
