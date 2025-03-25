class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String department;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.department,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: '${json['first_name']} ${json['last_name']}',
      role: json['is_staff'] ? 'manager' : 'employee',
      department: json['department'] ?? 'Not assigned',
    );
  }
}
