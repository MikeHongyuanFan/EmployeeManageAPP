import 'package:intl/intl.dart';

class WfhRequest {
  final int? id;
  final DateTime date;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime requestDate;
  final String? managerComment;

  WfhRequest({
    this.id,
    required this.date,
    required this.reason,
    required this.status,
    required this.requestDate,
    this.managerComment,
  });

  factory WfhRequest.fromJson(Map<String, dynamic> json) {
    return WfhRequest(
      id: json['id'],
      date: DateTime.parse(json['date']),
      reason: json['reason'],
      status: json['status'],
      requestDate: DateTime.parse(json['request_date']),
      managerComment: json['manager_comment'],
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      'date': formatter.format(date),
      'reason': reason,
    };
  }
}
