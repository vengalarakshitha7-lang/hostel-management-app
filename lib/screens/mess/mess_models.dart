import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackItem {
  final String id;
  final String message;
  final String status;
  final String managerNote;
  final int rating;

  FeedbackItem({
    required this.id,
    required this.message,
    required this.status,
    required this.managerNote,
    required this.rating,
  });

  // 🔥 THIS IS WHAT YOU WERE MISSING
  factory FeedbackItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FeedbackItem(
      id: doc.id,
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      managerNote: data['managerNote'] ?? '',
      rating: data['rating'] ?? 0,
    );
  }
}