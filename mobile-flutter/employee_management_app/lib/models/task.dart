import 'package:flutter/material.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final int assignedById;
  final String assignedByName;
  final int assignedToId;
  final String assignedToName;
  final String dueDate;
  final String priority;
  final String status;
  final String createdAt;
  final String updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedById,
    required this.assignedByName,
    required this.assignedToId,
    required this.assignedToName,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      assignedById: json['assigned_by_id'],
      assignedByName: json['assigned_by_name'] ?? '',
      assignedToId: json['assigned_to_id'],
      assignedToName: json['assigned_to_name'] ?? '',
      dueDate: json['due_date'],
      priority: json['priority'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_by_id': assignedById,
      'assigned_by_name': assignedByName,
      'assigned_to_id': assignedToId,
      'assigned_to_name': assignedToName,
      'due_date': dueDate,
      'priority': priority,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'not_started':
        return Colors.grey;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.pending_actions;
      case 'not_started':
        return Icons.schedule;
      case 'overdue':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }
}
