import 'package:intl/intl.dart';

class LeaveRequest {
  final int? id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime requestDate;
  final String? managerComment;

  LeaveRequest({
    this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.requestDate,
    this.managerComment,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      leaveType: json['leave_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'],
      status: json['status'],
      requestDate: DateTime.parse(json['request_date']),
      managerComment: json['manager_comment'],
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      'leave_type': leaveType,
      'start_date': formatter.format(startDate),
      'end_date': formatter.format(endDate),
      'reason': reason,
    };
  }

  int get durationDays {
    return endDate.difference(startDate).inDays + 1;
  }
}
