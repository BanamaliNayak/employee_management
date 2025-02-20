import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequest {
  String id;
  String userId;
  String userName;
  String reason;
  DateTime startDate;
  DateTime endDate;
  String status; // pending, approved, rejected
  String? attachmentUrl; // optional attachment
  String leaveType; // Annual, Sick, etc.

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.leaveType,
    this.attachmentUrl,
  });

  // Convert LeaveRequest to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'reason': reason,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'leaveType': leaveType,
      'attachmentUrl': attachmentUrl,
    };
  }

  // Convert Firestore data (Map) to LeaveRequest object
  factory LeaveRequest.fromMap(Map<String, dynamic> map) {
    return LeaveRequest(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      reason: map['reason'],
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.parse(map['startDate']),
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.parse(map['endDate']),
      status: map['status'],
      leaveType: map['leaveType'] ?? 'Unknown',
      attachmentUrl: map['attachmentUrl'],
    );
  }
}
