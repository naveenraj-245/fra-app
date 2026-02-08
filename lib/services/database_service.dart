import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  // Get a reference to the main database
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Function to save a new Claim Application
  Future<void> submitClaim({
    required String name,
    required String tribe,
    required String village,
    double? lat,
    double? lng,
    // We will add map coordinates later
  }) async {
    try {
      // Create a unique ID for the claim based on time
      String claimId = "CLAIM-${DateTime.now().millisecondsSinceEpoch}";

      // Create a 'Map' (like a JSON object) of data
      Map<String, dynamic> claimData = {
        "id": claimId,
        "applicantName": name,
        "tribe": tribe,
        "village": village,
        "location": {        // NEW: Save as a nested object
          "lat": lat,
          "lng": lng,
        },
        "status": "Pending",
        // ... rest of data
      };

      // Send it to the 'claims' collection in Firestore
      await _db.collection('claims').doc(claimId).set(claimData);
      
      debugPrint("Claim Submitted Successfully!");
    } catch (e) {
      debugPrint("Error submitting claim: $e");
      rethrow; // Pass the error up so the UI can show it
    }
  }
}