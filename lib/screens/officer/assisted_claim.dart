import 'package:flutter/material.dart';

class AssistedClaimScreen extends StatefulWidget {
  const AssistedClaimScreen({super.key});

  @override
  State<AssistedClaimScreen> createState() => _AssistedClaimScreenState();
}

class _AssistedClaimScreenState extends State<AssistedClaimScreen> {
  int _currentStep = 0;

  // Controllers specific to Officer entry
  final _beneficiaryIdController = TextEditingController(); 
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Assisted Claim"),
        backgroundColor: const Color(0xFF0D47A1), // Officer Navy Blue
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            // Submit Logic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Assisted Claim Submitted Successfully!")),
            );
            Navigator.pop(context);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep -= 1);
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentStep == 2 ? "SUBMIT CLAIM" : "NEXT"),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Back"),
                  ),
              ],
            ),
          );
        },
        steps: [
          // STEP 1: BENEFICIARY INFO (Officer Specific)
          Step(
            title: const Text("Beneficiary Identity"),
            content: Column(
              children: [
                // Highlighted Field for Officer
                Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color(0xFFE3F2FD),
                  child: TextFormField(
                    controller: _beneficiaryIdController,
                    decoration: const InputDecoration(
                      labelText: "Beneficiary Aadhar / ID Number",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge, color: Color(0xFF0D47A1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),

          // STEP 2: LAND DETAILS
          Step(
            title: const Text("Land Information"),
            content: Column(
              children: [
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "GPS Coordinates (Lat, Long)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                    suffixIcon: Icon(Icons.my_location), 
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: "Estimated Area (Acres)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.landscape),
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),

          // STEP 3: EVIDENCE
          Step(
            title: const Text("Digital Evidence"),
            content: Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                      const Text("Tap to take photo of land"),
                    ],
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}