import 'package:flutter/material.dart';

class PriorityIcon extends StatelessWidget {
  final String priority;
  final double size;
  
  const PriorityIcon({
    Key? key, 
    required this.priority,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (priority.toLowerCase()) {
      case 'high':
        iconData = Icons.priority_high;
        color = Colors.red;
        break;
      case 'medium':
        iconData = Icons.remove_circle;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.arrow_downward;
        color = Colors.green;
    }

    return Icon(
      iconData, 
      color: color,
      size: size,
    );
  }
}
