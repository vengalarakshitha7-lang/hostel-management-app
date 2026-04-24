import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FoodCountService {

  /// 🔥 LUNCH COUNTS
  static Future<Map<String, int>> getLunchCounts() async {
    final db = FirebaseFirestore.instance;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var snapshot = await db
        .collection('selections')
        .where('date', isEqualTo: today)
        .get();

    Map<String, int> counts = {};

    for (var doc in snapshot.docs) {
      var lunch = doc['lunch'];

      if (lunch != null) {
        (lunch as Map<String, dynamic>).forEach((item, qty) {
          int quantity = (qty as num).toInt();
          counts[item] = (counts[item] ?? 0) + quantity;
        });
      }
    }

    return counts; // ✅ IMPORTANT (fixes null error)
  }

  /// 🔥 DINNER COUNTS
  static Future<Map<String, int>> getDinnerCounts() async {
    final db = FirebaseFirestore.instance;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var snapshot = await db
        .collection('selections')
        .where('date', isEqualTo: today)
        .get();

    Map<String, int> counts = {};

    for (var doc in snapshot.docs) {
      var dinner = doc['dinner'];

      if (dinner != null) {
        (dinner as Map<String, dynamic>).forEach((item, qty) {
          int quantity = (qty as num).toInt();
          counts[item] = (counts[item] ?? 0) + quantity;
        });
      }
    }

    return counts; // ✅ IMPORTANT
  }
}
