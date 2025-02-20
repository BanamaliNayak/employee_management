import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/leave_request.dart';

class ManagerLeaveApprovalScreen extends StatefulWidget {
  @override
  _ManagerLeaveApprovalScreenState createState() =>
      _ManagerLeaveApprovalScreenState();
}

class _ManagerLeaveApprovalScreenState
    extends State<ManagerLeaveApprovalScreen> {
  // Function to update leave request status
  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(id)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to format date correctly
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    } else if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'Invalid Date';
  }

  // Function to display leave request details
  Widget _buildLeaveRequestTile(LeaveRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(request.userName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason: ${request.reason}'),
            Text(
                'Duration: ${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}'),
            Text('Type: ${request.leaveType}'),
            if (request.attachmentUrl != null)
              GestureDetector(
                onTap: () => _viewAttachment(request.attachmentUrl!),
                child: const Text('View Attachment',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline)),
              ),
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

  // Function to open the attachment (can be expanded to open in a browser)
  void _viewAttachment(String url) {
    print('Opening attachment: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Leave Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leave_requests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading requests'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending requests'));
          }

          List<LeaveRequest> requests = snapshot.data!.docs
              .map((doc) =>
              LeaveRequest.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) =>
                _buildLeaveRequestTile(requests[index]),
          );
        },
      ),
    );
  }
}
