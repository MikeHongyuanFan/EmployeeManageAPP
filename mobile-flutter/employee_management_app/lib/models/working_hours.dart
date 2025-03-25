class WorkingTime {
  final int id;
  final int userId;
  final String userName;
  final String date;
  final String clockIn;
  final String? clockOut;
  final int? totalMinutes;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final String? description;
  final String workType;

  WorkingTime({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.clockIn,
    this.clockOut,
    this.totalMinutes,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.workType = 'office',
  });

  factory WorkingTime.fromJson(Map<String, dynamic> json) {
    return WorkingTime(
      id: json['id'],
      userId: json['user_id'] ?? json['user'] ?? 0,
      userName: json['user_name'] ?? '',
      date: json['date'],
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
      totalMinutes: json['total_minutes'],
      notes: json['notes'],
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
      description: json['description'] ?? json['notes'],
      workType: json['work_type'] ?? 'office',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'date': date,
      'clock_in': clockIn,
      'clock_out': clockOut,
      'total_minutes': totalMinutes,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'description': description,
      'work_type': workType,
    };
  }

  String get formattedTotalTime {
    if (totalMinutes == null) return 'In progress';
    
    final hours = totalMinutes! ~/ 60;
    final minutes = totalMinutes! % 60;
    
    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }
  
  // Calculate hours worked based on clock in and clock out times
  double get hoursWorked {
    if (totalMinutes == null) {
      if (clockOut != null && clockIn != null) {
        try {
          final inTime = DateTime.parse(clockIn);
          final outTime = DateTime.parse(clockOut!);
          return outTime.difference(inTime).inMinutes / 60.0;
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }
    return totalMinutes! / 60.0;
  }
}
