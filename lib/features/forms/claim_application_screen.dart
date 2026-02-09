import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClaimApplicationScreen extends StatefulWidget {
  const ClaimApplicationScreen({super.key});

  @override
  State<ClaimApplicationScreen> createState() => _ClaimApplicationScreenState();
}

class _ClaimApplicationScreenState extends State<ClaimApplicationScreen> {
  // --- STATE VARIABLES ---
  int _currentStep = 0;
  final PageController _pageController = PageController();
  bool _isSubmitting = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _aadharController = TextEditingController();
  
  // Map Data
  final MapController _mapController = MapController();
  List<LatLng> _boundaryPoints = [];

  // --- SUBMISSION LOGIC ---
  Future<void> _submitClaim() async {
    if (_nameController.text.isEmpty || _boundaryPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill details and mark land boundary.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // 1. Convert Map Points to Firebase GeoPoints
      List<GeoPoint> boundaryGeoPoints = _boundaryPoints
          .map((p) => GeoPoint(p.latitude, p.longitude))
          .toList();

      // 2. Prepare Data
      final claimData = {
        'userId': user.uid,
        'status': 'Submitted',
        'submittedAt': FieldValue.serverTimestamp(),
        'beneficiary': {
          'fullName': _nameController.text.trim(),
          'fatherName': _fatherNameController.text.trim(),
          'aadhar': _aadharController.text.trim(),
        },
        'landData': {
          'boundary': boundaryGeoPoints,
          'center': boundaryGeoPoints.isNotEmpty 
              ? GeoPoint(boundaryGeoPoints[0].latitude, boundaryGeoPoints[0].longitude) 
              : null,
          'totalPoints': boundaryGeoPoints.length,
        }
      };

      // 3. Save to Firestore
      await FirebaseFirestore.instance.collection('claims').add(claimData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Claim Submitted Successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- NAVIGATION LOGIC ---
  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitClaim();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Land Claim"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Progress Bar
          _buildProgressBar(),

          // 2. Main Content (PageView)
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              children: [
                _buildStep1Beneficiary(),
                _buildStep2Map(),
                _buildStep3Review(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  // ==========================================
  // STEP 1: BENEFICIARY DETAILS
  // ==========================================
  Widget _buildStep1Beneficiary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Beneficiary Details", Icons.person),
          const SizedBox(height: 15),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildFancyInput("Full Name", Icons.badge, _nameController),
                  const SizedBox(height: 20),
                  _buildFancyInput("Father/Spouse Name", Icons.family_restroom, _fatherNameController),
                  const SizedBox(height: 20),
                  _buildFancyInput("Aadhar Number", Icons.credit_card, _aadharController, isNumber: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2: MAP & LAND IDENTIFICATION
  // ==========================================
  Widget _buildStep2Map() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            // 1. Use a fixed start point (Odisha) to avoid World View (Image 1 issue)
            initialCenter: const LatLng(20.2961, 85.8245), 
            initialZoom: 15.0,
            onTap: (tapPosition, point) {
              setState(() {
                _boundaryPoints.add(point);
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.fra_app',
            ),
            
            // 2. Only draw the Polygon Layer if we have points
            if (_boundaryPoints.isNotEmpty)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _boundaryPoints,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                    // Note: A valid polygon needs at least 3 points, 
                    // but flutter_map usually handles <3 gracefully by just drawing lines.
                  ),
                ],
              ),

            // 3. Draw Markers for every tap (visual feedback)
            MarkerLayer(
              markers: _boundaryPoints.map((p) => Marker(
                point: p,
                width: 12,
                height: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),

        // --- INSTRUCTIONS BANNER ---
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  _boundaryPoints.isEmpty 
                      ? "Tap map to mark start point" 
                      : "Marking Point ${_boundaryPoints.length + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // --- FLOATING TOOLS ---
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: "undo",
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                child: const Icon(Icons.undo),
                onPressed: () {
                  if (_boundaryPoints.isNotEmpty) {
                    setState(() => _boundaryPoints.removeLast());
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 3: REVIEW
  // ==========================================
  Widget _buildStep3Review() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
           const SizedBox(height: 20),
           const Text("Ready to Submit?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
           const SizedBox(height: 10),
           Text("Beneficiary: ${_nameController.text}", style: const TextStyle(fontSize: 16)),
           Text("Points Marked: ${_boundaryPoints.length}", style: const TextStyle(fontSize: 16)),
           const SizedBox(height: 30),
           const Text(
             "By clicking submit, this data will be sent to the FRA database for verification.",
             textAlign: TextAlign.center,
             style: TextStyle(color: Colors.grey),
           ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildProgressBar() {
    return Container(
      color: Colors.green[800],
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          _stepIcon(0, "Details"),
          _line(),
          _stepIcon(1, "Map Land"),
          _line(),
          _stepIcon(2, "Review"),
        ],
      ),
    );
  }

  Widget _stepIcon(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? Colors.white : Colors.white38,
          child: isActive 
            ? Icon(Icons.check, size: 16, color: Colors.green[800]) 
            : Text("${step + 1}", style: TextStyle(color: Colors.green[800], fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal))
      ],
    );
  }

  Widget _line() {
    return Expanded(child: Container(height: 2, color: Colors.white38, margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10)));
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[800], size: 28),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900])),
      ],
    );
  }

  Widget _buildFancyInput(String label, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  side: const BorderSide(color: Colors.grey)
                ),
                child: const Text("Back", style: TextStyle(color: Colors.black)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: _isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_currentStep == 2 ? "SUBMIT CLAIM" : "NEXT STEP"),
            ),
          ),
        ],
      ),
    );
  }
}