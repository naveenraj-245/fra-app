import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Added for Officer Mode
import '../../screens/officer/application_details.dart'; // ✅ To open details

class FraMapScreen extends StatefulWidget {
  final bool isOfficerMode;
  
  const FraMapScreen({super.key, this.isOfficerMode = false});

  @override
  State<FraMapScreen> createState() => _FraMapScreenState();
}

class _FraMapScreenState extends State<FraMapScreen> {
  // 📍 Default Center (Nilgiris)
  final LatLng _center = const LatLng(11.4064, 76.6932);
  final MapController _mapController = MapController();

  // DWELLER MODE VARIABLES
  List<LatLng> _boundaryPoints = [];
  bool _isLoading = true;
  
  // CONNECTIVITY VARIABLES
  bool _isOnline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    
    // Only load saved boundary if we are acting as a Dweller (Marking Land)
    if (!widget.isOfficerMode) {
      _loadSavedBoundary();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // 📡 CHECK CONNECTIVITY
  Future<void> _initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool isConnected = results.contains(ConnectivityResult.mobile) || 
                       results.contains(ConnectivityResult.wifi);
    if (mounted) setState(() => _isOnline = isConnected);
  }

  // 💾 DWELLER: LOAD/SAVE/CLEAR LOGIC
  Future<void> _loadSavedBoundary() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_land_boundary');
    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);
      setState(() {
        _boundaryPoints = decoded.map((p) => LatLng(p['lat'], p['lng'])).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOffline() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _boundaryPoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()
    );
    await prefs.setString('saved_land_boundary', encodedData);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Saved to Device! 💾")));
  }

  Future<void> _saveOnline() async {
    await _saveOffline(); // Backup locally first
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.blue, content: Text("Syncing to Server... ☁️")));
  }

  Future<void> _clearBoundary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_land_boundary');
    setState(() => _boundaryPoints.clear());
  }

  // ===============================================================
  // 🎨 BUILD METHOD
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    // 🔀 SWITCH: If Officer -> Show Review Map. If Dweller -> Show Marking Map.
    return widget.isOfficerMode 
        ? _buildOfficerMap() 
        : _buildDwellerMap();
  }

  // 👮 OFFICER VIEW: Live Markers from Firebase
  Widget _buildOfficerMap() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Field Verification Map"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('claims').snapshots(),
        builder: (context, snapshot) {
          List<Marker> markers = [];
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['location'] != null && data['location'] is GeoPoint) {
                GeoPoint pos = data['location'];
                markers.add(
                  Marker(
                    point: LatLng(pos.latitude, pos.longitude),
                    width: 50, height: 50,
                    child: GestureDetector(
                      onTap: () => _showOfficerPreview(data),
                      child: _buildMarkerIcon(data['status'] ?? "Pending"),
                    ),
                  ),
                );
              }
            }
          }
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _center, initialZoom: 13.0),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () => _mapController.move(_center, 13.0),
      ),
    );
  }

  // 🏡 DWELLER VIEW: Drawing Boundaries (Your existing logic)
  Widget _buildDwellerMap() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Land Boundary"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _boundaryPoints.isNotEmpty ? () => setState(() => _boundaryPoints.removeLast()) : null,
          ),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: _clearBoundary),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) => setState(() => _boundaryPoints.add(point)),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    maxNativeZoom: 18, maxZoom: 22,
                  ),
                  if (_boundaryPoints.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: _boundaryPoints,
                        color: (_isOnline ? Colors.blue : Colors.green).withValues(alpha: 0.3),
                          borderColor: _isOnline ? Colors.blueAccent : Colors.greenAccent,
                          borderStrokeWidth: 3,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: _boundaryPoints.map((point) => Marker(
                      point: point, width: 15, height: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          border: Border.all(color: _isOnline ? Colors.blue : Colors.green, width: 2),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
              // STATUS & SAVE BUTTON
              Positioned(
                bottom: 30, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${_boundaryPoints.length} Points Marked", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Row(
                            children: [
                              Icon(_isOnline ? Icons.wifi : Icons.wifi_off, size: 14, color: _isOnline ? Colors.blue : Colors.orange),
                              const SizedBox(width: 4),
                              Text(_isOnline ? "Online Mode" : "Offline Mode", style: TextStyle(color: _isOnline ? Colors.blue : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isOnline ? Colors.blue[700] : Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _boundaryPoints.length >= 3 ? (_isOnline ? _saveOnline : _saveOffline) : null,
                        icon: Icon(_isOnline ? Icons.cloud_upload : Icons.save_alt),
                        label: Text(_isOnline ? "Save Online" : "Save Offline"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // --- HELPERS FOR OFFICER MODE ---
  Widget _buildMarkerIcon(String status) {
    Color color = status == 'Approved' ? Colors.green : (status == 'Rejected' ? Colors.red : Colors.orange);
    return Icon(Icons.location_on, color: color, size: 40);
  }

  void _showOfficerPreview(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 200,
        child: Column(
          children: [
            Text(data['applicantName'] ?? "Unknown", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Status: ${data['status']}", style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Ensure you update your ApplicationDetailsScreen to handle safe data types as per previous fix!
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicationDetailsScreen(claimData: data)));
                },
                child: const Text("View Details"),
              ),
            )
          ],
        ),
      ),
    );
  }
}