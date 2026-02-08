import 'package:cloud_firestore/cloud_firestore.dart';

class GrievanceModel {
  final String? id;
  final String userId;
  final String type;
  final String description;
  final String status;
  final DateTime submittedAt;
  final String? adminResponse;

  GrievanceModel({
    this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.status,
    required this.submittedAt,
    this.adminResponse,
  });

  // Convert a Grievance object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'description': description,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'adminResponse': adminResponse,
    };
  }

  // Create a Grievance object from a Firestore document
  factory GrievanceModel.fromMap(Map<String, dynamic> map, String docId) {
    return GrievanceModel(
      id: docId,
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'General',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
      adminResponse: map['adminResponse'],
    );
  }
}