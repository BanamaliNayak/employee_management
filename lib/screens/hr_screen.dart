import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'employee_directory_screen.dart';
import 'manager_leave_approval_screen.dart';

class HrScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HrScreen({super.key, required this.userData});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
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
        title: const Text('HR Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 160,
                width: 340,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardScreen()),
                    );
                  },
                  child: const Text('Dashboard & Analytics', style: TextStyle(fontSize: 20),),
                ),
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                height: 160,
                width: 340,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmployeeDirectoryScreen()),
                    );
                  },
                  child: const Text('Employee Directory',style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                height: 160,
                width: 340,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManagerLeaveApprovalScreen()),
                    );
                  },
                  child: const Text('Leave Approval',style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
