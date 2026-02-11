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
  final _nameController = TextEditingController();
  final _tribeController = TextEditingController();
  final _aadharController = TextEditingController();
  
  // MAP DATA (The points user marks)
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(11.4064, 76.6932); // Nilgiris
  final List<LatLng> _boundaryPoints = [];

  final DatabaseService _dbService = DatabaseService();
  bool _isSubmitting = false;
  @override
  void dispose() {
    _nameController.dispose();
    _tribeController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Land Claim"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      // We use a Stepper to guide the user
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () async {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            // --- REAL SUBMIT LOGIC ---
            setState(() => _isSubmitting = true);

            try {
              await _dbService.submitClaim(
                name: _nameController.text.trim(),
                type: "Individual Land", // You can make this a dropdown later
                area: "2.5", // Get this from your controller
                address: "Nilgiris Forest Zone", // Get this from controller
                phone: "9876543210", // Get from controller
                lat: 11.41, // Get from Location Controller
                lng: 76.69,
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
                Navigator.pop(context); // Close form
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
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(_currentStep == 2 ? "SUBMIT CLAIM" : "NEXT STEP"),
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
            content: Column(
              children: [
                // 👇 Show Aadhar Field if Officer is Assisting
                if (widget.isAssisted) ...[
                  const Text(
                    "Officer Assisted Application",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _aadharController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    decoration: const InputDecoration(
                      labelText: "Applicant Aadhar Number *",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                      helperText: "Enter 12-digit Aadhar Number of the applicant",
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _tribeController,
                  decoration: const InputDecoration(labelText: "Tribe / Community", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                const TextField(
                  decoration: InputDecoration(labelText: "Village Name", border: OutlineInputBorder()),
                ),
              ],
            ),
          ),

          // ---------------- STEP 2: MARK LAND ON MAP ----------------
          Step(
            title: const Text("Map Land"),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: SizedBox(
              height: 400, // Fixed height for map inside stepper
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
                  // MAP CONTROLS (Undo/Clear)
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
                  // INSTRUCTION BANNER
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
                  _buildReviewRow("Applicant:", _nameController.text.isEmpty ? "Sky" : _nameController.text),
                  _buildReviewRow("Tribe:", _tribeController.text.isEmpty ? "Irula" : _tribeController.text),
                  const Divider(),
                  _buildReviewRow("Land Points:", "${_boundaryPoints.length} corners marked"),
                  _buildReviewRow("Est. Area:", "2.5 Acres (Auto-calc)"),
                  const SizedBox(height: 10),
                  const Text("Status: Ready to Submit", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
