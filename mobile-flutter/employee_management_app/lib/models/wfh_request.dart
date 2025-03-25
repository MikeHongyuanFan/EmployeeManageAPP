import 'package:flutter/material.dart';

class WfhRequest {
  final int id;
  final int userId;
  final String userName;
  final String date;
  final String reason;
  final String status;
  final String? rejectionReason;
  final String createdAt;
  final String updatedAt;

  WfhRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.reason,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WfhRequest.fromJson(Map<String, dynamic> json) {
    return WfhRequest(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? '',
      date: json['date'],
      reason: json['reason'] ?? '',
      status: json['status'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'date': date,
      'reason': reason,
      'status': status,
      'rejection_reason': rejectionReason,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
  }
}
