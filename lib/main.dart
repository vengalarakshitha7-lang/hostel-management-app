import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_hostel_mngment_01/welcomescreen.dart';
import 'screens/role_handler_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/mess/mess_dashboard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HostelApp());
}

class HostelApp extends StatelessWidget {
  const HostelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hostel Management System',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const WelcomeScreen()
          : const RoleHandlerScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/role_handler': (context) => const RoleHandlerScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/mess': (context) => const MessDashboard(),
      },
    );
  }
}
