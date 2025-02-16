import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'employee_profile_screen.dart';

class EmployeeDirectoryScreen extends StatefulWidget {
  @override
  _EmployeeDirectoryScreenState createState() =>
      _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('employees').get();

    employees = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();

    setState(() {
      filteredEmployees = employees;
    });
  }

  void filterSearch(String query) {
    setState(() {
      filteredEmployees = employees
          .where((employee) =>
      employee['name'].toLowerCase().contains(query.toLowerCase()) ||
          employee['department']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Directory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Employees...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: filterSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(employee['name'][0].toUpperCase()),
                  ),
                  title: Text(employee['name']),
                  subtitle: Text('${employee['designation']} - ${employee['department']}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmployeeProfileScreen(employee: employee),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
