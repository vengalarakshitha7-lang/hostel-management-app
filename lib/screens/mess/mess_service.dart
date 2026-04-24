import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/mess_models.dart';

class MessService {
  final db = FirebaseFirestore.instance;

  // 🔥 FOOD COUNT STREAM
  Stream<Map<String, int>> getFoodCounts() {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return db
        .collection('selections')
        .where('date', isEqualTo: today)
        .snapshots()
        .map((snapshot) {
      Map<String, int> counts = {};

      for (var doc in snapshot.docs) {
        var data = doc.data();

        void process(Map<String, dynamic>? meal) {
          if (meal == null) return;

          meal.forEach((item, qty) {
            counts[item] = (counts[item] ?? 0) + (qty as int);
          });
        }

        process(data['lunch'] != null ? Map<String, dynamic>.from(data['lunch']) : null);
        process(data['dinner'] != null ? Map<String, dynamic>.from(data['dinner']) : null);
      }

      return counts;
    });
  }

  // 🔥 FEEDBACK STREAM
  Stream<List<FeedbackItem>> getFeedbackStream() {
    return db
        .collection('feedback')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FeedbackItem.fromFirestore(doc)).toList();
    });
  }

  // 🔥 RESOLVE
  Future<void> resolveFeedback(String id, String note) {
    return db.collection('feedback').doc(id).update({
      "status": "resolved",
      "managerNote": note,
    });
  }

  // 🔥 MENU CONTROL
  Future<void> setSpecialMenu(List<String> items) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await db.collection('menus').doc(today).set({
      'type': 'special',
      'items': items,
      'date': today,
    });
  }
}
