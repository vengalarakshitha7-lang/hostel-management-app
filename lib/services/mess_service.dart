import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/mess_models.dart';

class MessService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // --- 1. Feedback ---
  Stream<List<FeedbackItem>> getFeedbackStream() {
    return _db.collection('feedbacks')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FeedbackItem.fromFirestore(doc)).toList());
  }

  Future<void> resolveFeedback(String id, String note) async {
    await _db.collection('feedbacks').doc(id).update({
      'status': 'resolved',
      'managerNote': note,
    });
  }

  // --- 2. Menu ---
  Stream<DocumentSnapshot> getTodayMenu() {
    return _db.collection('menus').doc(today).snapshots();
  }

  Future<void> setSpecialMenu(List<String> items) async {
    await _db.collection('menus').doc(today).set({
      'type': 'special',
      'items': items,
      'date': today,
    });
  }

  // --- 3. Food Counts & Aggregation ---
  Stream<Map<String, int>> getFoodCounts() {
    return _db.collection('selections')
        .where('date', isEqualTo: today)
        .snapshots()
        .map((snapshot) {
      Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Aggregate Lunch
        if (data['lunch'] != null) {
          (data['lunch'] as Map).forEach((item, qty) {
            counts[item.toString()] = (counts[item.toString()] ?? 0) + (qty as int);
          });
        }
        // Aggregate Dinner
        if (data['dinner'] != null) {
          (data['dinner'] as Map).forEach((item, qty) {
            counts[item.toString()] = (counts[item.toString()] ?? 0) + (qty as int);
          });
        }
      }
      return counts;
    });
  }

  // --- 4. Attendance Stats ---
  Stream<Map<String, int>> getAttendanceStats() {
    return _db.collection('users')
        .where('role', isEqualTo: 'Student')
        .snapshots()
        .map((snapshot) {
      int total = snapshot.docs.length;
      int present = snapshot.docs.where((doc) {
        final d = doc.data();
        return d.containsKey('attendance') && d['attendance'] == 'present';
      }).length;
      return {'total': total, 'present': present, 'absent': total - present};
    });
  }
}
