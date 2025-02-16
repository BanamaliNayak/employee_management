import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Employee> _employees = [];

  List<Employee> get employees => _employees;

  Future<void> fetchEmployees() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('employees').get();
      _employees = snapshot.docs.map((doc) => Employee.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }
}
