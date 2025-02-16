import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leave_provider.dart';
import '../models/leave_request.dart';

class ManagerLeaveApprovalScreen extends StatefulWidget {
  @override
  _ManagerLeaveApprovalScreenState createState() =>
      _ManagerLeaveApprovalScreenState();
}

class _ManagerLeaveApprovalScreenState
    extends State<ManagerLeaveApprovalScreen> {
  List<LeaveRequest> pendingRequests = [];

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('leave_requests')
        .where('status', isEqualTo: 'pending')
        .get();

    List<LeaveRequest> requests = snapshot.docs
        .map((doc) => LeaveRequest.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    setState(() {
      pendingRequests = requests;
    });
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    // Update status in Firestore via LeaveProvider.
    await Provider.of<LeaveProvider>(context, listen: false)
        .updateLeaveStatus(id, newStatus);

    // (Optional) Update employee leave balance here if approved.
    // You can call updateLeaveBalance if needed.

    // Simulate sending a push notification.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Leave request $newStatus')),
    );

    // Refresh the list.
    fetchPendingRequests();
  }

  Widget _buildLeaveRequestTile(LeaveRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(request.userName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason: ${request.reason}'),
            Text(
                'Duration: ${request.startDate.toLocal().toString().split(" ")[0]} - ${request.endDate.toLocal().toString().split(" ")[0]}'),
            if (request.attachmentUrl != null)
              Text('Attachment: ${request.attachmentUrl}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _updateStatus(request.id, 'approved'),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _updateStatus(request.id, 'rejected'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Leave Requests'),
      ),
      body: pendingRequests.isEmpty
          ? const Center(child: Text('No pending requests'))
          : ListView.builder(
        itemCount: pendingRequests.length,
        itemBuilder: (context, index) {
          return _buildLeaveRequestTile(pendingRequests[index]);
        },
      ),
    );
  }
}
