import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  
  const StatusChip({Key? key, required this.status}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;
    String label = status.substring(0, 1).toUpperCase() + status.substring(1);
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        backgroundColor = Colors.red;
        icon = Icons.cancel;
        break;
      case 'completed':
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'in progress':
        backgroundColor = Colors.blue;
        icon = Icons.sync;
        break;
      default:
        backgroundColor = Colors.grey;
        icon = Icons.info;
    }
    
    return Chip(
      avatar: Icon(
        icon,
        color: textColor,
        size: 16,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
        ),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
