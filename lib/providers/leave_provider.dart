import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/leave_request.dart';

class LeaveProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get status => null;

  Future<void> requestLeave(LeaveRequest leaveRequest) async {
    await _firestore.collection('leave_requests').doc(leaveRequest.id).set(leaveRequest.toMap());
    notifyListeners();
  }

  Future<List<LeaveRequest>> fetchLeaveRequests() async {
    final snapshot = await _firestore.collection('leave_requests').get();
    return snapshot.docs.map((doc) => LeaveRequest.fromMap(doc.data())).toList();
  }

  Future<void> updateLeaveStatus(String leaveId, String status) async {
    await _firestore.collection('leave_requests').doc(leaveId).update({'status': status});
    notifyListeners();
  }

  Future<void> updateLeaveBalance(String userId, int days) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userData = await userRef.get();
    if (userData.exists) {
      int currentBalance = userData.data()?['leave_balance'] ?? 0;
      if (status == 'approved' && currentBalance >= days) {
        await userRef.update({'leave_balance': currentBalance - days});
      }
    }
    notifyListeners();
  }
}
