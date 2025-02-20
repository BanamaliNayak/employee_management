import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/leave_request.dart';

class LeaveApplicationScreen extends StatefulWidget {
  const LeaveApplicationScreen({super.key});

  @override
  _LeaveApplicationScreenState createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  final TextEditingController reasonController = TextEditingController();
  String leaveType = 'Annual Leave';
  DateTime? startDate;
  DateTime? endDate;
  String? attachmentName;
  String? attachmentUrl;
  bool isSubmitting = false;

  // Function to submit leave application
  Future<void> submitLeaveApplication() async {
    if (startDate == null || endDate == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      String leaveId = Uuid().v4();
      LeaveRequest leaveRequest = LeaveRequest(
        id: leaveId,
        userId: user.uid,
        userName: user.displayName ?? 'Unknown User',
        reason: reasonController.text,
        leaveType: leaveType,
        startDate: startDate!,
        endDate: endDate!,
        status: 'pending',
        attachmentUrl: attachmentUrl,
      );

      await FirebaseFirestore.instance.collection('leave_requests').doc(leaveId).set(leaveRequest.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave application submitted'), backgroundColor: Colors.green),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  // Function to select a date
  Future<void> selectDate(BuildContext context, bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : (startDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          startDate = pickedDate;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = startDate; // Adjust end date if it's before start date
          }
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  // Function to upload an attachment
  Future<void> selectAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      setState(() => attachmentName = result.files.first.name);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading: $attachmentName...')),
      );

      try {
        String fileName = '${Uuid().v4()}_${result.files.first.name}';
        Reference storageRef = FirebaseStorage.instance.ref().child('leave_attachments/$fileName');

        UploadTask uploadTask = storageRef.putData(result.files.first.bytes!);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() => attachmentUrl = downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attachment uploaded successfully!'), backgroundColor: Colors.green),
        );
      } catch (e) {
        setState(() {
          attachmentName = null;
          attachmentUrl = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
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
            // Dropdown for Leave Type
            DropdownButtonFormField<String>(
              value: leaveType,
              items: ['Annual Leave', 'Sick Leave', 'Unpaid Leave', 'Work-from-Home']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() => leaveType = value!),
              decoration: const InputDecoration(labelText: 'Leave Type'),
            ),
            const SizedBox(height: 10),

            // Reason TextField
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason for Leave'),
            ),
            const SizedBox(height: 10),

            // Start and End Date Pickers
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

            // Attachment Upload Button
            ElevatedButton(
              onPressed: selectAttachment,
              child: Text(attachmentName == null
                  ? 'Select Attachment (Optional)'
                  : 'Attachment: $attachmentName'),
            ),
            const SizedBox(height: 20),

            // Submit Button
            isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: submitLeaveApplication,
              child: const Text('Submit Leave Request'),
            ),
          ],
        ),
      ),
    );
  }
}
