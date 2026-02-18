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
  final String? imageUrl;       // URL of the uploaded image
  final Map<String, double>? location; // Lat/Lng

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
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 80, // Compress slightly for faster uploads
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // --- Location Logic ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable GPS.')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to get location.')));
    } finally {
      setState(() => _isLoading = false);
    }
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
      backgroundColor: const Color(0xFFF5F7FA), // Modern light background
      appBar: AppBar(
        title: const Text("File a Grievance"),
        backgroundColor: const Color(0xFFD32F2F), // Red for alerts
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // --- Notice Banner ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50], 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: Colors.red.withOpacity(0.3))
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your report is secure and will be sent directly to the District Authority.", 
                        style: TextStyle(color: Colors.red)
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Form Container ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16), 
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Issue Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), 
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16)
                      ),
                      items: _grievanceTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                    const SizedBox(height: 20),

                    const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Explain what happened in detail...", 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      validator: (val) => val!.isEmpty ? "Please enter details" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Evidence Container ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16), 
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Attach Evidence", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50], 
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), 
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: _imageFile == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center, 
                                children: [
                                  Icon(Icons.add_a_photo, size: 30, color: Colors.grey), 
                                  SizedBox(height: 8), 
                                  Text("Tap to take a photo", style: TextStyle(color: Colors.grey))
                                ]
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12), 
                                child: Image.file(_imageFile!, fit: BoxFit.cover)
                              ),
                      ),
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Current Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
                        TextButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 18),
                          label: Text(_currentPosition == null ? "Mark GPS" : "Updated"),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
                        ),
                      ],
                    ),
                    if (_currentPosition != null)
                      Text(
                        "Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}", 
                        style: TextStyle(color: Colors.green[700], fontSize: 12)
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F), 
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _isLoading ? null : _submitGrievance,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("SUBMIT REPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}