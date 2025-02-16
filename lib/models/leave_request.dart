class LeaveRequest {
  String id;
  String userId;
  String userName;
  String reason;
  DateTime startDate;
  DateTime endDate;
  String status; // pending, approved, rejected
  String? attachmentUrl; // optional attachment (simulated)

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'reason': reason,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory LeaveRequest.fromMap(Map<String, dynamic> map) {
    return LeaveRequest(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      reason: map['reason'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      status: map['status'],
      attachmentUrl: map['attachmentUrl'],
    );
  }
}
