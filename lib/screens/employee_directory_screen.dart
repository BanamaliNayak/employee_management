import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'employee_profile_screen.dart';

class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  _EmployeeDirectoryScreenState createState() => _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  bool isLoading = true; // Track loading state
  String errorMessage = ''; // Track errors

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('employees').get();

      employees = snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...?doc.data() as Map<String, dynamic>? // Ensure data is not null
      })
          .toList();

      setState(() {
        filteredEmployees = employees;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching employees: $e");
      setState(() {
        errorMessage = "Failed to load employees. Please try again.";
        isLoading = false;
      });
    }
  }

  Future<void> addEmployee(String name, String designation, String department) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance.collection('employees').add({
        'name': name,
        'designation': designation,
        'department': department,
      });

      setState(() {
        employees.add({'id': docRef.id, 'name': name, 'designation': designation, 'department': department});
        filteredEmployees = List.from(employees);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Employee added successfully"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("Error adding employee: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to add employee"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void showAddEmployeeDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController designationController = TextEditingController();
    final TextEditingController departmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Employee"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: designationController,
              decoration: const InputDecoration(labelText: "Designation"),
            ),
            TextField(
              controller: departmentController,
              decoration: const InputDecoration(labelText: "Department"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String name = nameController.text.trim();
              String designation = designationController.text.trim();
              String department = departmentController.text.trim();

              if (name.isNotEmpty && designation.isNotEmpty && department.isNotEmpty) {
                addEmployee(name, designation, department);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("All fields are required"),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void filterSearch(String query) {
    setState(() {
      filteredEmployees = employees
          .where((employee) =>
      (employee['name']?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (employee['department']?.toLowerCase().contains(query.toLowerCase()) ?? false))
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
                : filteredEmployees.isEmpty
                ? const Center(child: Text("No employees found"))
                : ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index] ?? {}; // Ensure it's not null
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (employee['name']?.isNotEmpty ?? false)
                          ? employee['name'][0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(employee['name'] ?? 'Unknown'),
                  subtitle: Text('${employee['designation'] ?? 'N/A'} - ${employee['department'] ?? 'N/A'}'),
                  onTap: () {
                    if (employee.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeProfileScreen(employee: employee),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddEmployeeDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
