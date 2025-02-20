import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/leave_request.dart';

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final TextEditingController _reasonController = TextEditingController();
  String _leaveType = 'Annual Leave';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;
  String? _userName; // Store user name
  String? _userId;   // Store user ID

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to fetch user details (name) from Firestore
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userId = user.uid;
          _userName = user.displayName ?? 'Unknown User';
        });
      } else {
        setState(() {
          _userId = user.uid;
          _userName = 'Unknown User';
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
      setState(() {
        _userName = 'Unknown User';
      });
    }
  }

  // Function to submit leave request
  Future<void> _submitLeaveRequest() async {
    if (_startDate == null || _endDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_userId == null || _userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching user details!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String leaveId = Uuid().v4();

      LeaveRequest leaveRequest = LeaveRequest(
        id: leaveId,
        userId: _userId!,
        userName: _userName!,
        reason: _reasonController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        status: 'pending',
        leaveType: _leaveType,
      );

      await FirebaseFirestore.instance.collection('leave_requests').doc(leaveId).set(leaveRequest.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave request submitted successfully!"), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // Function to select start or end date
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : _startDate ?? DateTime.now(),
      firstDate: isStart ? DateTime.now() : _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Leave")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Show user's name (loading if not fetched yet)
            Text(
              _userName != null ? "User: $_userName" : "Loading user info...",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _leaveType,
              items: ['Annual Leave', 'Sick Leave', 'Unpaid Leave', 'Work-from-Home']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => _leaveType = value!),
              decoration: const InputDecoration(labelText: 'Leave Type'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: "Reason"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(_startDate == null
                      ? "Select Start Date"
                      : "Start: ${_startDate!.toLocal()}".split(' ')[0]),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(_endDate == null
                      ? "Select End Date"
                      : "End: ${_endDate!.toLocal()}".split(' ')[0]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitLeaveRequest,
              child: const Text("Submit Leave Request"),
            ),
          ],
        ),
      ),
    );
  }
}
