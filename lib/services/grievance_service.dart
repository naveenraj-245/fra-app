import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grievance_model.dart';

class GrievanceService {
  final CollectionReference _grievanceCollection =
      FirebaseFirestore.instance.collection('grievances');

  // 1. CREATE: Submit a new grievance
  Future<void> addGrievance(GrievanceModel grievance) async {
    try {
      await _grievanceCollection.add(grievance.toMap());
    } catch (e) {
      throw Exception("Failed to submit grievance: $e");
    }
  }

  // 2. READ: Get all grievances for a specific user (Stream for real-time updates)
  Stream<List<GrievanceModel>> getUserGrievances(String userId) {
    return _grievanceCollection
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GrievanceModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 3. READ: Get specific grievance details
  Future<GrievanceModel?> getGrievanceById(String id) async {
    try {
      DocumentSnapshot doc = await _grievanceCollection.doc(id).get();
      if (doc.exists) {
        return GrievanceModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching grievance: $e");
    }
  }
}
