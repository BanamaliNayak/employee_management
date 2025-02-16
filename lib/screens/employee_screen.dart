import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'leave_application_screen.dart';
import 'employee_directory_screen.dart';

class EmployeeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EmployeeScreen({super.key, required this.userData});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaveApplicationScreen()),
                );
              },
              child: const Text('Apply for Leave'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmployeeDirectoryScreen()),
                );
              },
              child: const Text('Employee Directory'),
            ),
            // Optionally, add a button for viewing leave balance or profile details.
          ],
        ),
      ),
    );
  }
}
