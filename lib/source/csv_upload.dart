import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CSVUploadService {
  static Future<void> uploadCSV() async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    try {
      print("🚀 Starting CSV Import & Auth Creation...");
      final rawData = await rootBundle.loadString('assets/users_data_03.csv');
      
      List<String> lines = rawData.split(RegExp(r'\r?\n'));

      int successCount = 0;

      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        var row = line.split(',');
        bool hasData = row.any((cell) => cell.trim().isNotEmpty);
        if (!hasData) continue;

        if (row.length < 6) continue;

        String rollNo = row[0].trim();
        String name = row[1].trim();
        String branch = row[2].trim();
        String email = row[3].trim();
        String phone = row[4].trim();
        String password = row[5].trim();

        try {
          // 1. Auth Account
          try {
            await auth.createUserWithEmailAndPassword(email: email, password: password);
          } on FirebaseAuthException catch (e) {
            if (e.code != 'email-already-in-use') rethrow;
          }

          // 2. Firestore Document (including attendance)
          await db.collection('users').doc(email).set({
            "rollNo": rollNo,
            "name": name,
            "branch": branch,
            "email": email,
            "phone": phone,
            "role": "Student",
            "attendance": "present", // Initializing field
            "createdAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          successCount++;
        } catch (e) {
          print("🔥 Error processing $email: $e");
        }
      }
      print("🎊 CSV Import Finished! Total accounts: $successCount");
      
      // Also run the safety initialization for any pre-existing users
      await addAttendanceToAllUsers();
      
    } catch (e) {
      print("❌ Critical CSV Error: $e");
    }
  }

  // Safety function to ensure ALL users have the attendance field
  static Future<void> addAttendanceToAllUsers() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    int count = 0;

    for (var doc in snapshot.docs) {
      var data = doc.data();
      if (!data.containsKey('attendance')) {
        batch.update(doc.reference, {'attendance': 'present'});
        count++;
      }
    }
    
    if (count > 0) {
      await batch.commit();
      print("✅ Attendance field added to $count existing users");
    } else {
      print("✅ All users already have attendance fields");
    }
  }
}
