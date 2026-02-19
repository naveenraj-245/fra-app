import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/database_service.dart';

class ClaimApplicationScreen extends StatefulWidget {
  final bool isAssisted;
  
  const ClaimApplicationScreen({super.key, this.isAssisted = false});

  @override
  State<ClaimApplicationScreen> createState() => _ClaimApplicationScreenState();
}

class _ClaimApplicationScreenState extends State<ClaimApplicationScreen> {
  int _currentStep = 0;
  
  // Form Controllers
  final _formKey = GlobalKey<FormState>(); // ✅ NEW: Form Key for validation
  final _nameController = TextEditingController();
  final _tribeController = TextEditingController();
  final _villageController = TextEditingController(); // Added controller
  final _areaController = TextEditingController(); // Added controller for 4-Hectare Rule
  final _aadharController = TextEditingController();
  
  // MAP DATA
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(11.4064, 76.6932); // Nilgiris
  final List<LatLng> _boundaryPoints = [];

  final DatabaseService _dbService = DatabaseService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tribeController.dispose();
    _villageController.dispose();
    _areaController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  // --- STRICT FRA VALIDATORS ---
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Name is required";
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return "Name must only contain letters (No numbers/symbols)";
    }
    return null;
  }

  String? _validateAadhar(String? value) {
    if (value == null || value.trim().isEmpty) return "Aadhar is required";
    if (!RegExp(r"^\d{12}$").hasMatch(value)) {
      return "Aadhar must be exactly 12 digits";
    }
    return null;
  }

  String? _validateArea(String? value) {
    if (value == null || value.trim().isEmpty) return "Estimated area required";
    double? area = double.tryParse(value);
    if (area == null) return "Must be a valid number";
    if (area <= 0) return "Area must be greater than 0";
    if (area > 4.0) return "FRA Rule Limit: Cannot claim more than 4 Hectares"; // ✅ FRA Legal Rule
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Land Claim"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () async {
          // Block advancing if Form 1 is invalid
          if (_currentStep == 0) {
            if (!_formKey.currentState!.validate()) return; 
            setState(() => _currentStep += 1);
          } else if (_currentStep == 1) {
            // Block advancing if map has no points
            if (_boundaryPoints.length < 3) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Draw a boundary with at least 3 points"), backgroundColor: Colors.orange),
              );
              return;
            }
            setState(() => _currentStep += 1);
          } else {
            // --- REAL SUBMIT LOGIC ---
            setState(() => _isSubmitting = true);

            try {
              await _dbService.submitClaim(
                name: _nameController.text.trim(),
                type: "Individual Land", 
                area: _areaController.text.trim(), 
                address: _villageController.text.trim(),
                phone: "9876543210", 
                lat: _boundaryPoints.first.latitude, 
                lng: _boundaryPoints.first.longitude,
                isAssisted: widget.isAssisted,
                beneficiaryId: widget.isAssisted ? _aadharController.text : null,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Claim Submitted Successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); 
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            } finally {
              if (mounted) setState(() => _isSubmitting = false);
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            Navigator.pop(context);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_currentStep == 2 ? "SUBMIT CLAIM" : "NEXT STEP"),
                  ),
                ),
                const SizedBox(width: 15),
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: const Text("BACK"),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: [
          // ---------------- STEP 1: PERSONAL DETAILS ----------------
          Step(
            title: const Text("Details"),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey, // ✅ Real-time interaction wrapper
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  if (widget.isAssisted) ...[
                    const Text(
                      "Officer Assisted Application",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _aadharController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      validator: _validateAadhar, // ✅ Real-time Aadhar check
                      decoration: const InputDecoration(
                        labelText: "Applicant Aadhar Number *",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                  TextFormField(
                    controller: _nameController,
                    validator: _validateName, // ✅ Real-time Name check
                    decoration: const InputDecoration(labelText: "Full Name *", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _tribeController,
                    validator: (val) => val == null || val.isEmpty ? "Required field" : null,
                    decoration: const InputDecoration(labelText: "Tribe / Community *", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _villageController,
                    validator: (val) => val == null || val.isEmpty ? "Required field" : null,
                    decoration: const InputDecoration(labelText: "Village Name *", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                    validator: _validateArea, // ✅ Real-time 4-Hectare FRA check
                    decoration: const InputDecoration(
                      labelText: "Estimated Area (in Hectares) *", 
                      border: OutlineInputBorder(),
                      helperText: "FRA Limit: Max 4.0 Hectares",
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------- STEP 2: MARK LAND ON MAP ----------------
          Step(
            title: const Text("Map Land"),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: SizedBox(
              height: 400, 
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _center,
                        initialZoom: 15.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _boundaryPoints.add(point);
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          maxNativeZoom: 18,
                          maxZoom: 22,
                        ),
                        if (_boundaryPoints.isNotEmpty)
                          PolygonLayer(
                            polygons: [
                              Polygon(
                                points: _boundaryPoints,
                                color: Colors.green.withValues(alpha: 0.4),
                                borderColor: Colors.greenAccent,
                                borderStrokeWidth: 3,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: _boundaryPoints.map((p) => Marker(
                            point: p,
                            width: 15, height: 15,
                            child: const Icon(Icons.circle, color: Colors.white, size: 15),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10, right: 10,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: "undo",
                          backgroundColor: Colors.white,
                          onPressed: _boundaryPoints.isNotEmpty 
                            ? () => setState(() => _boundaryPoints.removeLast()) 
                            : null,
                          child: const Icon(Icons.undo, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton.small(
                          heroTag: "clear",
                          backgroundColor: Colors.white,
                          onPressed: () => setState(() => _boundaryPoints.clear()),
                          child: const Icon(Icons.delete_forever, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  if (_boundaryPoints.isEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Tap map corners to mark boundary",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ---------------- STEP 3: REVIEW ----------------
          Step(
            title: const Text("Review"),
            isActive: _currentStep >= 2,
            content: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewRow("Applicant:", _nameController.text.isEmpty ? "Missing" : _nameController.text),
                  _buildReviewRow("Tribe:", _tribeController.text.isEmpty ? "Missing" : _tribeController.text),
                  _buildReviewRow("Area Claimed:", "${_areaController.text} Hectares"),
                  const Divider(),
                  _buildReviewRow("Land Points:", "${_boundaryPoints.length} corners marked"),
                  const SizedBox(height: 10),
                  const Text("Status: Verified & Ready to Submit", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}