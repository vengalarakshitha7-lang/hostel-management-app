import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackItem {
  final String id;
  final String studentId;
  final String message;
  final double rating;
  final String status;
  final String? managerNote;
  final DateTime timestamp;

  FeedbackItem({
    required this.id,
    required this.studentId,
    required this.message,
    required this.rating,
    required this.status,
    this.managerNote,
    required this.timestamp,
  });

  factory FeedbackItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FeedbackItem(
      id: doc.id,
      studentId: data['studentId'] ?? 'Unknown',
      message: data['message'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      managerNote: data['managerNote'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
