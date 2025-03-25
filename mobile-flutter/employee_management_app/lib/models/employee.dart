class Employee {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String employeeId;
  final String position;
  final String departmentName;
  final String joinDate;
  final Map<String, int> leaveBalance;
  final bool isActive;
  final String? phone;
  final String? address;
  final String? emergencyContact;
  final String? managerName;
  final String? dateJoined;

  Employee({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.employeeId,
    required this.position,
    required this.departmentName,
    required this.joinDate,
    required this.leaveBalance,
    required this.isActive,
    this.phone,
    this.address,
    this.emergencyContact,
    this.managerName,
    this.dateJoined,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      employeeId: json['employee_id'],
      position: json['position'],
      departmentName: json['department_name'],
      joinDate: json['join_date'],
      leaveBalance: Map<String, int>.from(json['leave_balance'] ?? {}),
      isActive: json['is_active'] ?? true,
      phone: json['phone'],
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      managerName: json['manager_name'],
      dateJoined: json['date_joined'] ?? json['join_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'employee_id': employeeId,
      'position': position,
      'department_name': departmentName,
      'join_date': joinDate,
      'leave_balance': leaveBalance,
      'is_active': isActive,
      'phone': phone,
      'address': address,
      'emergency_contact': emergencyContact,
      'manager_name': managerName,
      'date_joined': dateJoined,
    };
  }

  String get fullName => '$firstName $lastName';
}
