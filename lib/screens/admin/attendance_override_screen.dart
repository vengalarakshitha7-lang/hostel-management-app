import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class AttendanceOverrideScreen extends StatelessWidget {
  const AttendanceOverrideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Override"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getStudentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading students"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final students = snapshot.data!.docs;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final data = student.data() as Map<String, dynamic>;
              final String email = student.id;
              final String name = data['name'] ?? 'No Name';
              final String rollNo = data['rollNo'] ?? 'N/A';
              final String attendance = data['attendance'] ?? 'absent';

              return ListTile(
                title: Text(name),
                subtitle: Text(rollNo),
                trailing: Switch(
                  value: attendance == 'present',
                  onChanged: (value) async {
                    String newStatus = value ? 'present' : 'absent';
                    await firestoreService.updateAttendance(email, newStatus);
                  },
                  activeColor: Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
