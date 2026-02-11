import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. SUBMIT A NEW CLAIM
  Future<void> submitClaim({
    required String name,
    required String type, // 'Individual', 'Community', etc.
    required String area,
    required String address,
    required String phone,
    required double lat,
    required double lng,
    bool isAssisted = false, // Was it filed by an officer?
    String? beneficiaryId,   // If assisted, who is it for?
  }) async {
    User? user = _auth.currentUser;
    if (user == null) throw "User not logged in";

    // Create a unique ID for the claim (e.g., CLM-12345)
    String claimId = "CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    await _db.collection('claims').doc(claimId).set({
      'id': claimId,
      'userId': user.uid,
      'applicantName': name,
      'type': type,
      'area': area,
      'address': address,
      'phone': phone,
      'location': GeoPoint(lat, lng), // Store GPS
      'status': 'Pending',            // Default status
      'submittedAt': FieldValue.serverTimestamp(),
      'isAssisted': isAssisted,
      'beneficiaryId': beneficiaryId ?? "",
      'officerId': isAssisted ? user.uid : null, // If officer filed it, track them
    });
  }

  // 2. GET ALL CLAIMS (For Officer Dashboard)
  Stream<QuerySnapshot> getClaimsStream(String statusFilter) {
    return _db
        .collection('claims')
        .where('status', isEqualTo: statusFilter)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // 3. UPDATE CLAIM STATUS (Approve/Reject)
  Future<void> updateClaimStatus(String claimId, String newStatus) async {
    await _db.collection('claims').doc(claimId).update({
      'status': newStatus,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}