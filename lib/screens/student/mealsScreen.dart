import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MealsScreen extends StatefulWidget {
  final String studentEmail;
  const MealsScreen({super.key, required this.studentEmail});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  bool isLoading = true;
  String studentName = "Student";

  List<String> lunchItems = [];
  List<String> dinnerItems = [];

  // ✅ SAFE MAPS
  Map<String, int> lunchSelections = {};
  Map<String, int> dinnerSelections = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ✅ FETCH DATA SAFELY
  Future<void> _fetchData() async {
    try {
      String day =
      DateFormat('EEEE').format(DateTime.now()).toLowerCase();

      var menuDoc = await FirebaseFirestore.instance
          .collection('weekly_menu')
          .doc(day)
          .get();

      var studentQuery = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: widget.studentEmail)
          .get();

      if (!mounted) return;

      var data = menuDoc.data() ?? {};

      setState(() {
        lunchItems = _parseMenu(data['lunch']);
        dinnerItems = _parseMenu(data['dinner']);

        if (studentQuery.docs.isNotEmpty) {
          studentName = studentQuery.docs.first.data()['name'] ?? "Student";
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ✅ SAFE PARSER
  List<String> _parseMenu(dynamic data) {
    if (data == null) return [];
    if (data is List) return List<String>.from(data);
    if (data is String) {
      return data.split('+').map((e) => e.trim()).toList();
    }
    return [];
  }

  // ✅ SAFE STATE UPDATE
  void updateItem(String mealType, String item, int qty) {
    setState(() {
      Map<String, int> map =
      mealType == "lunch" ? lunchSelections : dinnerSelections;

      if (qty <= 0) {
        map.remove(item);
      } else {
        map[item] = qty;
      }
    });
  }

  // ✅ SAVE TO FIRESTORE SAFELY
  Future<void> _confirmSelection() async {
    if (lunchSelections.isEmpty && dinnerSelections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one item")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("selections").add({
        "studentId": widget.studentEmail,
        "studentName": studentName,
        "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "lunch": Map<String, dynamic>.from(lunchSelections),
        "dinner": Map<String, dynamic>.from(dinnerSelections),
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meals confirmed successfully!")),
      );

      // ✅ CLEAR AFTER SAVE
      setState(() {
        lunchSelections.clear();
        dinnerSelections.clear();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
    DateFormat('E, MMM d').format(DateTime.now());

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),


            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Meal Selection",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Text(formattedDate,
                    style: const TextStyle(color: Colors.blue)),
              ],
            ),

            const SizedBox(height: 20),

            // 🍱 LUNCH
            if (lunchItems.isNotEmpty)
              _buildMealCard(
                  "lunch", "Lunch", lunchItems, lunchSelections),

            const SizedBox(height: 16),

            // 🍽 DINNER
            if (dinnerItems.isNotEmpty)
              _buildMealCard(
                  "dinner", "Dinner", dinnerItems, dinnerSelections),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  "Confirm Selection",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ ITEM UI
  Widget _buildMealCard(
      String mealType,
      String title,
      List<String> items,
      Map<String, int> selections) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          Column(
            children: items.map((item) {
              int qty = selections[item] ?? 0;

              return ListTile(
                title: Text(item),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: qty > 0
                          ? () =>
                          updateItem(mealType, item, qty - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text("$qty"),
                    IconButton(
                      onPressed: () =>
                          updateItem(mealType, item, qty + 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}