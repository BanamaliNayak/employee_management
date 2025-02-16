import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/leave_request.dart';
import '../providers/leave_provider.dart';
import 'package:uuid/uuid.dart';

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  void _submitLeaveRequest(BuildContext context) {
    if (_startDate == null ||
        _endDate == null ||
        _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("All fields are required")));
      return;
    }

    final leaveRequest = LeaveRequest(
      id: Uuid().v4(),
      userId: 'USER_ID',
      // Replace with actual user ID
      userName: 'John Doe',
      // Replace with actual user name
      reason: _reasonController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      status: 'pending',
    );

    Provider.of<LeaveProvider>(context, listen: false)
        .requestLeave(leaveRequest);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Leave request submitted")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Leave")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _reasonController,
                decoration: InputDecoration(labelText: "Reason")),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101));
                if (picked != null) setState(() => _startDate = picked);
              },
              child: Text(_startDate == null
                  ? "Select Start Date"
                  : _startDate!.toLocal().toString().split(' ')[0]),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime.now(),
                    lastDate: DateTime(2101));
                if (picked != null) setState(() => _endDate = picked);
              },
              child: Text(_endDate == null
                  ? "Select End Date"
                  : _endDate!.toLocal().toString().split(' ')[0]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => _submitLeaveRequest(context),
                child: Text("Submit Leave Request")),
          ],
        ),
      ),
    );
  }
}
