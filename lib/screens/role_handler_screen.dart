import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'student/student_dashboard.dart';
import 'admin/admin_dashboard.dart';
import 'mess/mess_dashboard.dart';

class RoleHandlerScreen extends StatefulWidget {
  const RoleHandlerScreen({super.key});

  @override
  State<RoleHandlerScreen> createState() => _RoleHandlerScreenState();
}

class _RoleHandlerScreenState extends State<RoleHandlerScreen> {

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final String email = user.email!;

    try {
      // 🎯 Fetch role from Firestore using Email as Document ID
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      String role = 'student'; // Default

      if (doc.exists) {
        role = (doc.data()?['role'] ?? 'student').toString().toLowerCase().trim();
      }

      if (!mounted) return;

      // 🎯 Route based on role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (role == 'mess manager' || role == 'mess' || role == 'mess_manager') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MessDashboard()),
        );
      } else {
        // Always pass email to StudentDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboard(email: email),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching role: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
