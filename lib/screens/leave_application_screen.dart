import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../models/leave_request.dart';
import '../providers/leave_provider.dart';

class LeaveApplicationScreen extends StatefulWidget {
  @override
  _LeaveApplicationScreenState createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  final TextEditingController reasonController = TextEditingController();
  String leaveType = 'Annual Leave';
  DateTime? startDate;
  DateTime? endDate;
  String? attachmentName; // Simulated file attachment

  Future<void> submitLeaveApplication() async {
    if (startDate == null || endDate == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    final leaveRequest = LeaveRequest(
      id: Uuid().v4(),
      userId: 'USER_ID',
      // Replace with actual user id
      userName: 'John Doe',
      // Replace with actual user name
      reason: reasonController.text,
      startDate: startDate!,
      endDate: endDate!,
      status: 'pending',
      attachmentUrl:
          attachmentName, // Store the selected file name or dummy URL
    );

    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(leaveRequest.id)
        .set(leaveRequest.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave application submitted')),
    );

    Navigator.pop(context);
  }

  Future<void> selectDate(BuildContext context, bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  Future<void> selectAttachment() async {
    // Use file_picker to choose a file.
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        // Simulate file upload by storing the file name.
        attachmentName = result.files.first.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected attachment: $attachmentName')),
      );
    } else {
      // User canceled the picker.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Leave')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: leaveType,
              items: [
                'Annual Leave',
                'Sick Leave',
                'Unpaid Leave',
                'Work-from-Home'
              ]
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => leaveType = value!),
              decoration: const InputDecoration(labelText: 'Leave Type'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason for Leave'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => selectDate(context, true),
                  child: Text(startDate == null
                      ? 'Select Start Date'
                      : 'Start: ${startDate!.toLocal()}'.split(' ')[0]),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => selectDate(context, false),
                  child: Text(endDate == null
                      ? 'Select End Date'
                      : 'End: ${endDate!.toLocal()}'.split(' ')[0]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectAttachment,
              child: Text(attachmentName == null
                  ? 'Select Attachment (Optional)'
                  : 'Attachment: $attachmentName'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitLeaveApplication,
              child: const Text('Submit Leave Request'),
            ),
          ],
        ),
      ),
    );
  }
}
