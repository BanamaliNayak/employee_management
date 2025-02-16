import 'package:flutter/material.dart';

class EmployeeProfileScreen extends StatelessWidget {
  final Map<String, dynamic> employee;

  const EmployeeProfileScreen({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(employee['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(radius: 40, child: Text(employee['name'][0].toUpperCase())),
            ),
            const SizedBox(height: 20),
            Text('Designation: ${employee['designation']}', style: const TextStyle(fontSize: 18)),
            Text('Department: ${employee['department']}', style: const TextStyle(fontSize: 18)),
            Text('Email: ${employee['email']}', style: const TextStyle(fontSize: 18)),
            Text('Phone: ${employee['phone']}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
