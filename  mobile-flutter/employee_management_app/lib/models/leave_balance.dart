class LeaveBalance {
  final int id;
  final int userId;
  final int annualLeave;
  final int sickLeave;
  final int personalLeave;
  final int bonusHours;
  final int year;

  LeaveBalance({
    required this.id,
    required this.userId,
    required this.annualLeave,
    required this.sickLeave,
    required this.personalLeave,
    required this.bonusHours,
    required this.year,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'],
      userId: json['user_id'],
      annualLeave: json['annual_leave'],
      sickLeave: json['sick_leave'],
      personalLeave: json['personal_leave'],
      bonusHours: json['bonus_hours'],
      year: json['year'],
    );
  }
}
