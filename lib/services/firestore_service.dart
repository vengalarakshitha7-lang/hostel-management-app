import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/mess_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ATTENDANCE SYSTEM ---
  Stream<Map<String, int>> getAttendanceStats() {
    return _db.collection('users').where('role', isEqualTo: 'Student').snapshots().map((snapshot) {
      int total = snapshot.docs.length;
      int present = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['attendance'] == 'present') present++;
      }
      return {'total': total, 'present': present, 'absent': total - present};
    });
  }

  // --- FOOD COUNT AGGREGATION ---
  Stream<Map<String, int>> getFoodCounts() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _db.collection('selections').where('date', isEqualTo: today).snapshots().map((snapshot) {
      Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        void aggregate(Map? meal) {
          if (meal == null) return;
          meal.forEach((item, qty) {
            counts[item.toString()] = (counts[item.toString()] ?? 0) + (qty as int);
          });
        }
        aggregate(data['lunch'] as Map?);
        aggregate(data['dinner'] as Map?);
      }
      return counts;
    });
  }

  // --- FEEDBACK MANAGEMENT ---
  Future<void> submitFeedback(String studentName, String message) async {
    await _db.collection('feedback').add({
      'studentName': studentName,
      'message': message,
      'status': 'pending',
      'rating': 5,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<FeedbackItem>> getFeedbackStream() {
    return _db.collection('feedback').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FeedbackItem.fromFirestore(doc)).toList();
    });
  }

  Future<void> resolveFeedback(String id, String note) async {
    await _db.collection('feedback').doc(id).update({
      'status': 'resolved',
      'managerNote': note,
    });
  }

  // --- SPECIAL MENU CONTROL ---
  Stream<DocumentSnapshot> getMenuForDate(String date) {
    return _db.collection('menus').doc(date).snapshots();
  }

  Future<void> updateMenu({
    required String date,
    required String type,
    required List<String> lunchItems,
    required List<String> dinnerItems,
  }) async {
    await _db.collection('menus').doc(date).set({
      'type': type,
      'lunch': lunchItems,
      'dinner': dinnerItems,
      'date': date,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream of all students (used by Admin)
  Stream<QuerySnapshot> getStudentsStream() {
    return _db.collection('users').where('role', isEqualTo: 'Student').snapshots();
  }

  // Update attendance status (used by Admin)
  Future<void> updateAttendance(String email, String status) async {
    await _db.collection('users').doc(email).update({
      'attendance': status,
    });
  }
}
