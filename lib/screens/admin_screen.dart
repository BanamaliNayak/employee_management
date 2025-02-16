import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'employee_directory_screen.dart';
import 'manager_leave_approval_screen.dart';

class AdminScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AdminScreen({super.key, required this.userData});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
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
        title: const Text('Manager/Admin Dashboard'),
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
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
              child: const Text('Dashboard & Analytics'),
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManagerLeaveApprovalScreen()),
                );
              },
              child: const Text('Leave Approval'),
            ),
          ],
        ),
      ),
    );
  }
}
