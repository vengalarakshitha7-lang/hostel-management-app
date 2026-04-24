import 'package:cloud_firestore/cloud_firestore.dart';

class MessMenuService {
  static Future<void> uploadWeeklyMessMenu() async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;

      print("🔥 START UPLOAD");

      await db.collection("mess_menu_weekly").doc("monday").set({
        "lunch": ["Tomato Pulao", "Dal", "Salad"],
        "dinner": ["Rice", "Egg Curry", "Sambar"]
      });

      await db.collection("mess_menu_weekly").doc("tuesday").set({
        "lunch": ["Jeera Rice", "Dal", "Curd"],
        "dinner": ["Chole", "Rice", "Banana"]
      });

      await db.collection("mess_menu_weekly").doc("wednesday").set({
        "lunch": ["Rice", "Aloo Curry", "Sambar"],
        "dinner": ["Chicken Curry", "Rice", "Raita"]
      });

      await db.collection("mess_menu_weekly").doc("thursday").set({
        "lunch": ["Rice", "Dal", "Salad"],
        "dinner": ["Egg Curry", "Chapati", "Curd"]
      });

      await db.collection("mess_menu_weekly").doc("friday").set({
        "lunch": ["Veg Pulao", "Curd", "Salad"],
        "dinner": ["Biryani", "Raita", "Egg"]
      });

      await db.collection("mess_menu_weekly").doc("saturday").set({
        "lunch": ["Rice", "Dal", "Vegetable Curry"],
        "dinner": ["Chicken Curry", "Rice", "Sambar"]
      });

      await db.collection("mess_menu_weekly").doc("sunday").set({
        "lunch": ["Upma", "Chutney"],
        "dinner": ["Rice", "Paneer Curry", "Curd"]
      });

      print("✅ MENU UPLOADED SUCCESSFULLY");
    } catch (e) {
      print("❌ FIRESTORE ERROR: $e");
    }
  }
}