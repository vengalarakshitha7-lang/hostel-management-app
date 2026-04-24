import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/mess_models.dart';
import 'special_menu_screen.dart';

class MessDashboard extends StatefulWidget {
  const MessDashboard({super.key});

  @override
  State<MessDashboard> createState() => _MessDashboardState();
}

class _MessDashboardState extends State<MessDashboard> {
  final FirestoreService _service = FirestoreService();
  final Map<String, TextEditingController> _noteControllers = {};

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Mess Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Daily Attendance"),
            _buildAttendanceSection(),
            
            const SizedBox(height: 24),
            _buildSectionTitle("Food Requirement (Real-time)"),
            _buildRequirementSection(),
            
            const SizedBox(height: 24),
            _buildSectionTitle("Menu Management"),
            _buildMenuNavigationCard(), // New Navigation Card
            
            const SizedBox(height: 24),
            _buildSectionTitle("Student Feedback"),
            _buildFeedbackSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
    );
  }

  Widget _buildMenuNavigationCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SpecialMenuScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Update Today's Menu", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Set custom items for Lunch & Dinner", style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return StreamBuilder<Map<String, int>>(
      stream: _service.getAttendanceStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'total': 0, 'present': 0, 'absent': 0};
        return Row(
          children: [
            Expanded(child: _statCard("Present", "${stats['present']}", Icons.people, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _statCard("Absent", "${stats['absent']}", Icons.people_outline, Colors.orange)),
          ],
        );
      },
    );
  }

  Widget _buildRequirementSection() {
    return StreamBuilder<Map<String, int>>(
      stream: _service.getFoodCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _infoCard("No meal selections recorded for today yet.");
        }
        
        final counts = snapshot.data!;
        int mainCount = counts.values.fold(0, (prev, element) => prev + element);
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: counts.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text("${e.value} servings", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _reqCard("Rice", "${(mainCount * 0.18).toStringAsFixed(1)}kg", "🍚")),
                const SizedBox(width: 8),
                Expanded(child: _reqCard("Curry", "${(mainCount * 0.15).toStringAsFixed(1)}L", "🍛")),
                const SizedBox(width: 8),
                Expanded(child: _reqCard("Curd", "${(mainCount * 0.1).toStringAsFixed(1)}L", "🥛")),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildFeedbackSection() {
    return StreamBuilder<List<FeedbackItem>>(
      stream: _service.getFeedbackStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final feedbacks = snapshot.data ?? [];
        if (feedbacks.isEmpty) return _infoCard("No feedback received yet.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final fb = feedbacks[index];
            if (!_noteControllers.containsKey(fb.id)) {
              _noteControllers[fb.id] = TextEditingController(text: fb.managerNote);
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Rating: ${fb.rating}⭐", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        _statusChip(fb.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(fb.message, style: const TextStyle(fontSize: 15)),
                    const Divider(height: 24),
                    if (fb.status == 'pending') ...[
                      TextField(
                        controller: _noteControllers[fb.id],
                        decoration: const InputDecoration(hintText: "Add resolution note...", isDense: true),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _service.resolveFeedback(fb.id, _noteControllers[fb.id]!.text),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("Mark as Resolved"),
                        ),
                      )
                    ] else ...[
                      Text("Note: ${fb.managerNote}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statCard(String t, String v, IconData i, Color c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(i, color: c, size: 28),
        const SizedBox(height: 8),
        Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(t, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    );
  }

  Widget _reqCard(String label, String val, String emoji) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade50)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  Widget _statusChip(String status) {
    bool isResolved = status == 'resolved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isResolved ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: isResolved ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
      child: Text(msg, style: const TextStyle(color: Colors.blueGrey)),
    );
  }
}
