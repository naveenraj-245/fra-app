import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:geolocator/geolocator.dart'; 

class LandMapWidget extends StatefulWidget {
  // Sends the selected coordinate back to the parent form (Claim Screen)
  final Function(LatLng) onLocationSelected;

  const LandMapWidget({super.key, required this.onLocationSelected});

  @override
  State<LandMapWidget> createState() => _LandMapWidgetState();
}

class _LandMapWidgetState extends State<LandMapWidget> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation; 
  // Standard starting point (India Center)
  final LatLng _defaultCenter = const LatLng(20.5937, 78.9629); 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 5.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                  });
                  // Send coordinates back to the ClaimApplicationScreen
                  widget.onLocationSelected(point);
                },
              ), // <--- This closing parenthesis was missing in the snippet potentially
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.fra.project',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            
            // "Locate Me" Button
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _locateUser,
                backgroundColor: const Color(0xFF1B5E20),
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),

            // Instruction Label
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: const Text(
                  "Tap on the map to mark your land boundary.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- GPS Logic ---
  Future<void> _locateUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if GPS service is on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enable GPS Location services.")),
        );
      }
      return;
    }

    // 2. Handle Permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are permanently denied.")),
        );
      }
      return;
    }

    // 3. Get Current Position
    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng newLoc = LatLng(position.latitude, position.longitude);

      // 4. Move Map Camera
      _mapController.move(newLoc, 15.0); 
      
      // 5. Update UI & Notify Parent
      setState(() {
        _selectedLocation = newLoc;
      });
      widget.onLocationSelected(newLoc);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error finding location: $e")),
        );
      }
    }
  }
}