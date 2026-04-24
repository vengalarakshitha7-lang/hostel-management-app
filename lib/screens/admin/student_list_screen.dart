import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<Map<String, int>>(
            stream: firestoreService.getAttendanceStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final stats = snapshot.data ?? {'total': 0, 'present': 0, 'absent': 0};

              int totalStudents = stats['total']!;
              int present = stats['present']!;
              int absent = stats['absent']!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  const Text("Admin Dashboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _dashboardCard("TOTAL STUDENTS", totalStudents, Icons.people, Colors.blue)),
                      const SizedBox(width: 10),
                      Expanded(child: _dashboardCard("PRESENT", present, Icons.check_circle, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _dashboardCard("ABSENT", absent, Icons.cancel, Colors.red)),
                      const SizedBox(width: 10),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDailySummary(present, absent),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.apartment, color: Colors.blue),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My Hostel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Welcome, Admin User", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _dashboardCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(value.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDailySummary(int present, int absent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Daily Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryBar("Present", present.toDouble(), Colors.green),
              _summaryBar("Absent", absent.toDouble(), Colors.red),
            ],
          )
        ],
      ),
    );
  }

  Widget _summaryBar(String label, double value, Color color) {
    return Column(
      children: [
        Container(width: 20, height: value * 2, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10))
      ],
    );
  }
}
