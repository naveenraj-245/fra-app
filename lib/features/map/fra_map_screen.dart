import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FraMapScreen extends StatefulWidget {
  const FraMapScreen({super.key});

  @override
  State<FraMapScreen> createState() => _FraMapScreenState();
}

class _FraMapScreenState extends State<FraMapScreen> {
  // 1. Define the center point (Simulated Tribal Land Location)
  // You can change this to any lat/long you want to test.
  final LatLng _landCenter = const LatLng(20.2961, 85.8245); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Land Map"),
        backgroundColor: const Color(0xFF1B5E20), // Matches your dashboard green
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // --- THE MAP ---
          FlutterMap(
            options: MapOptions(
              initialCenter: _landCenter,
              initialZoom: 15.0,
            ),
            children: [
              // Layer A: Satellite/Street Tiles (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fra.project',
              ),

              // Layer B: The Land Boundary (Polygon)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: [
                      // Creating a square shape around the center to mimic a land plot
                      LatLng(_landCenter.latitude + 0.002, _landCenter.longitude - 0.002),
                      LatLng(_landCenter.latitude + 0.002, _landCenter.longitude + 0.002),
                      LatLng(_landCenter.latitude - 0.002, _landCenter.longitude + 0.002),
                      LatLng(_landCenter.latitude - 0.002, _landCenter.longitude - 0.002),
                    ],
                    color: Colors.green.withValues(alpha: 0.3), // Semi-transparent green fill
                    borderColor: const Color(0xFF1B5E20),
                    borderStrokeWidth: 3,
                  ),
                ],
              ),

              // Layer C: The "You are Here" Pin
              MarkerLayer(
                markers: [
                  Marker(
                    point: _landCenter,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --- INFO CARD (Overlay) ---
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Hug content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Plot #44-A (Claimed)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  const Text("Status: Verification Pending", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  const Text("Area: 4.2 Acres", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // Action for later: Download map for offline use
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Downloading Map for Offline Use...")),
                        );
                      },
                      icon: const Icon(Icons.download_for_offline),
                      label: const Text("Save Offline"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}