import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
// Since they are in the same 'forms' folder, we can import directly
import 'land_map_widget.dart'; 

class ClaimApplicationScreen extends StatefulWidget {
  const ClaimApplicationScreen({super.key});

  @override
  State<ClaimApplicationScreen> createState() => _ClaimApplicationScreenState();
}

class _ClaimApplicationScreenState extends State<ClaimApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  
  // Store the location selected from the map
  LatLng? _selectedLandLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Land Claim"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Beneficiary Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 15),

              // Aadhar Field
              TextFormField(
                controller: _aadharController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Aadhar Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 25),

              // --- THE MAP WIDGET INTEGRATION ---
              const Text("Identify Land Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("Tap on the map or use the GPS button to mark the center of the land.", 
                style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 10),
              
              LandMapWidget(
                onLocationSelected: (point) {
                  setState(() {
                    _selectedLandLocation = point;
                  });
                  print("Parent received: ${point.latitude}, ${point.longitude}");
                },
              ),

              const SizedBox(height: 10),
              
              // Location Feedback Text
              if (_selectedLandLocation != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Location Marked:\n${_selectedLandLocation!.latitude.toStringAsFixed(5)}, ${_selectedLandLocation!.longitude.toStringAsFixed(5)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedLandLocation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please mark the land on the map first.")),
                        );
                        return;
                      }
                      // Success Logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Application Submitted Successfully!")),
                      );
                    }
                  },
                  child: const Text("Submit Application"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}