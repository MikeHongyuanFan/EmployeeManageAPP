import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service_interface.dart';

class ApiService implements ApiServiceInterface {
  final String baseUrl = 'http://localhost:8000/api';
  String? _authToken;
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': _authToken != null ? 'Token $_authToken' : '',
  };
  
  @override
  String? get authToken => _authToken;
  
  @override
  set authToken(String? value) {
    _authToken = value;
  }
  
  @override
  int? userId;
  
  @override
  String? userName;
  
  @override
  bool? isManager;
  
  @override
  Future<void> initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
    userId = prefs.getInt('userId');
    userName = prefs.getString('userName');
    isManager = prefs.getBool('isManager');
  }
  
  @override
  Future<void> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: _headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to connect to API');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }
  
  @override
  Future<WfhRequest> createWfhRequest(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wfh-requests/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return WfhRequest.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create WFH request: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create WFH request: $e');
    }
  }
  
  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        userId = data['user_id'];
        userName = data['username'];
        isManager = data['is_manager'];
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _authToken!);
        await prefs.setInt('userId', userId!);
        await prefs.setString('userName', userName!);
        await prefs.setBool('isManager', isManager!);
        
        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: _headers,
      );
      
      // Clear local data
      _authToken = null;
      userId = null;
      userName = null;
      isManager = null;
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('userId');
      await prefs.remove('userName');
      await prefs.remove('isManager');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
  
  @override
  Future<List<Employee>> getEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get employees: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get employees: $e');
    }
  }
  
  @override
  Future<Employee> getEmployee(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees/$id/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get employee: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get employee: $e');
    }
  }
  
  @override
  Future<Employee> getCurrentEmployee() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees/current/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get current employee: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get current employee: $e');
    }
  }
  
  @override
  Future<Employee> getEmployeeProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
  
  @override
  Future<User> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/user/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
  
  @override
  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get tasks: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }
  
  @override
  Future<Task> createTask(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  Future<Task> updateTask(int taskId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/$taskId/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<Task> getTask(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$id/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get task: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }
  
  @override
  Future<List<LeaveRequest>> getLeaveRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leave-requests/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaveRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get leave requests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get leave requests: $e');
    }
  }
  
  @override
  Future<LeaveRequest> createLeaveRequest(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leave-requests/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return LeaveRequest.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create leave request: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create leave request: $e');
    }
  }
  
  @override
  Future<LeaveRequest> updateLeaveRequestStatus(int requestId, String status, {String? reason}) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      if (reason != null && reason.isNotEmpty) {
        data['rejection_reason'] = reason;
      }
      
      final response = await http.patch(
        Uri.parse('$baseUrl/leave-requests/$requestId/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return LeaveRequest.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update leave request: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update leave request: $e');
    }
  }
  
  @override
  Future<Map<String, int>> getLeaveBalance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leave-balance/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((key, value) => MapEntry(key, value as int));
      } else {
        throw Exception('Failed to get leave balance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get leave balance: $e');
    }
  }
  
  @override
  Future<List<Meeting>> getMeetings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meetings/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Meeting.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get meetings: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get meetings: $e');
    }
  }
  
  @override
  Future<Meeting> getMeeting(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meetings/$id/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return Meeting.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get meeting: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get meeting: $e');
    }
  }
  
  @override
  Future<Meeting> createMeeting(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/meetings/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return Meeting.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create meeting: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create meeting: $e');
    }
  }
  
  @override
  Future<Meeting> updateMeeting(int meetingId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/meetings/$meetingId/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return Meeting.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update meeting: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update meeting: $e');
    }
  }

  // Working time methods
  @override
  Future<List<WorkingTime>> getWorkingTimes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/working-hours/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WorkingTime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get working hours: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get working hours: $e');
    }
  }

  @override
  Future<WorkingTime> clockIn({String? notes}) async {
    try {
      final Map<String, dynamic> data = {};
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/working-hours/clock-in/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return WorkingTime.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to clock in: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to clock in: $e');
    }
  }

  @override
  Future<WorkingTime> clockOut({String? notes}) async {
    try {
      final Map<String, dynamic> data = {};
      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/working-hours/clock-out/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return WorkingTime.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to clock out: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to clock out: $e');
    }
  }
  
  @override
  Future<List<WorkingTime>> getWorkingHours() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/working-hours/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WorkingTime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get working hours: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get working hours: $e');
    }
  }
  
  @override
  Future<WorkingTime> logWorkingHours(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/working-hours/log/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return WorkingTime.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to log working hours: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to log working hours: $e');
    }
  }
  
  @override
  Future<List<WfhRequest>> getWfhRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wfh-requests/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WfhRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get WFH requests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get WFH requests: $e');
    }
  }
  
  @override
  Future<WfhRequest> updateWfhRequestStatus(int requestId, String status, {String? reason}) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      if (reason != null && reason.isNotEmpty) {
        data['rejection_reason'] = reason;
      }
      
      final response = await http.patch(
        Uri.parse('$baseUrl/wfh-requests/$requestId/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return WfhRequest.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update WFH request: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update WFH request: $e');
    }
  }
  
  @override
  Future<List<Document>> getDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get documents: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }
  
  @override
  Future<String> getDocumentDownloadUrl(int documentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents/$documentId/download/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['download_url'];
      } else {
        throw Exception('Failed to get document download URL: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get document download URL: $e');
    }
  }
  
  @override
  Future<Document> shareDocument(int documentId, List<int> employeeIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/documents/$documentId/share/'),
        headers: _headers,
        body: jsonEncode({'employee_ids': employeeIds}),
      );
      
      if (response.statusCode == 200) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to share document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to share document: $e');
    }
  }
  
  @override
  Future<void> deleteDocument(int documentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/documents/$documentId/'),
        headers: _headers,
      );
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
  
  @override
  Future<Document> updateDocument(int documentId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/documents/$documentId/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }
  
  @override
  Future<Document> uploadDocument(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/documents/'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to upload document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }
}
