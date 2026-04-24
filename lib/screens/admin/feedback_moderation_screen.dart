import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() =>
      _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final CollectionReference feedbackRef =
  FirebaseFirestore.instance.collection("feedback");

  /// ✅ Approve Feedback
  Future<void> approveFeedback(String docId) async {
    await feedbackRef.doc(docId).update({
      "status": "approved",
    });
  }

  /// ❌ Ignore Feedback (DO NOT DELETE)
  Future<void> ignoreFeedback(String docId) async {
    await feedbackRef.doc(docId).update({
      "status": "ignored",
    });
  }

  /// 🎨 Status Color
  Color getStatusColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "ignored":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  /// 🕒 Format Timestamp
  String formatTime(Timestamp? ts) {
    if (ts == null) return "";
    final date = ts.toDate();
    return "${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text("Admin Feedback Moderation"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: StreamBuilder<QuerySnapshot>(
          stream: feedbackRef
              .orderBy("timestamp", descending: true)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("No feedback available"));
            }

            var docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var data =
                docs[index].data() as Map<String, dynamic>;

                String message = data["message"] ?? "";
                String status = data["status"] ?? "pending";
                String action = data["actionTaken"] ?? "";
                String actionBy = data["actionBy"] ?? "";
                Timestamp? ts = data["actionTimestamp"];

                String docId = docs[index].id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        /// 🔹 Feedback Message
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// 🔹 Status Chip
                        Chip(
                          label: Text(status.toUpperCase()),
                          backgroundColor:
                          getStatusColor(status)
                              .withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: getStatusColor(status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// 🔹 Action Taken (if exists)
                        if (action.isNotEmpty) ...[
                          const SizedBox(height: 8),

                          Text(
                            "Action: $action",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),

                          if (actionBy.isNotEmpty)
                            Text("By: $actionBy"),

                          if (ts != null)
                            Text(
                              "At: ${formatTime(ts)}",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                        ],

                        const SizedBox(height: 10),

                        /// 🔹 Buttons ONLY if pending
                        if (status == "pending")
                          Row(
                            children: [

                              ElevatedButton(
                                onPressed: () =>
                                    approveFeedback(docId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Approve"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                onPressed: () =>
                                    ignoreFeedback(docId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Ignore"),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}