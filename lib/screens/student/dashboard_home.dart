import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class DashboardHome extends StatelessWidget {
  final String email;
   DashboardHome({super.key, required this.email});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ===============================
  /// 1️⃣ GET STUDENT NAME
  /// ===============================
  Future<String> getStudentName() async {
    var snapshot = await _db
        .collection('students')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['name'];
    }
    return "Student";
  }

  /// ===============================
  /// 2️⃣ LOCATION CHECK (CVR)
  /// ===============================
  Future<bool> isInsideCVR() async {
    const double cvrLat = 17.3560;
    const double cvrLng = 78.5440;

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      cvrLat,
      cvrLng,
    );

    return distance < 200; // meters
  }

  /// ===============================
  /// 3️⃣ UPDATE ATTENDANCE
  /// ===============================
  Future<void> markAttendance(
      String name, String status, BuildContext context) async {
    bool inside = await isInsideCVR();

    if (!inside) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ You are outside CVR campus")),
      );
      return;
    }

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await _db
        .collection('attendance')
        .doc(today)
        .collection('students')
        .doc(email)
        .set({
      'email': email,
      'name': name,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Marked $status")),
    );
  }

  /// ===============================
  /// 4️⃣ FULL UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getStudentName(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        String name = snapshot.data!;
        String today =
        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// 👋 Welcome
                Text(
                  "Welcome, $name 👋",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                /// 🔵 DATE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF56CCF2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Date",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(
                        today,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Windows: 7-10 AM / 4-6 PM",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🟠 LOCATION INFO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Attendance is only allowed within CVR College premises. Location will be verified.",
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 🟢🔴 BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            markAttendance(name, "present", context),
                        child: _box(
                          Colors.green,
                          Icons.check_circle,
                          "I'm Present",
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            markAttendance(name, "absent", context),
                        child: _box(
                          Colors.red,
                          Icons.cancel,
                          "I'm Absent",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


        );
      },
    );
  }

  /// 🎨 Attendance Box UI
  Widget _box(Color color, IconData icon, String text) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 10),
          Text(text,
              style:
              TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
