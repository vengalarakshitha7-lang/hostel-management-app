import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessMenuScreen extends StatefulWidget {
  const MessMenuScreen({super.key});

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  final TextEditingController lunch = TextEditingController();
  final TextEditingController dinner = TextEditingController();

  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> saveMenu() async {
    await FirebaseFirestore.instance
        .collection('special_menu')
        .doc(today)
        .set({
      "lunch": lunch.text.split(','),
      "dinner": dinner.text.split(','),
    });

    lunch.clear();
    dinner.clear();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Saved")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Special Menu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: lunch, decoration: const InputDecoration(labelText: "Lunch")),
            const SizedBox(height: 10),
            TextField(controller: dinner, decoration: const InputDecoration(labelText: "Dinner")),
            const SizedBox(height: 10),

            ElevatedButton(onPressed: saveMenu, child: const Text("Save")),

            const SizedBox(height: 20),

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('special_menu')
                  .doc(today)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return const Text("No menu");
                }

                var data = snapshot.data!.data()!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Lunch: ${data['lunch'].join(', ')}"),
                    Text("Dinner: ${data['dinner'].join(', ')}"),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}