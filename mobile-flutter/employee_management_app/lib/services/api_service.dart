import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service_interface.dart';

class ApiService implements ApiServiceInterface {
  // Additional methods required by the interface
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
  Future<String> getDocumentDownloadUrl(int documentId) async {
    return '$baseUrl/documents/$documentId/download/';
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
  Future<Employee> getEmployeeProfile() async {
    return getCurrentEmployee();
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
  Future<User> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me/'),
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
  Future<List<WorkingTime>> getWorkingHours() async {
    return getWorkingTimes();
  }
  
  @override
  Future<WorkingTime> logWorkingHours(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/working-hours/'),
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
  
  @override
  Future<WfhRequest> updateWfhRequestStatus(int requestId, String status, {String? reason}) async {
    try {
      final Map<String, dynamic> data = {'status': status};
      if (reason != null) {
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
        throw Exception('Failed to update WFH request status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update WFH request status: $e');
    }
  }
  // Use a getter for baseUrl so we can change it at runtime if needed
  static String _baseUrl = 'http://10.0.2.2:8000/api';
  
  static String get baseUrl => _baseUrl;
  
  // Allow changing the base URL for testing on different devices
  static void setBaseUrl(String url) {
    _baseUrl = url;
    print('API base URL changed to: $_baseUrl');
  }
  
  String? _authToken;
  
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

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Token $_authToken';
    }
    
    return headers;
  }

  @override
  Future<void> initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    userId = prefs.getInt('user_id');
    userName = prefs.getString('user_name');
    isManager = prefs.getBool('is_manager') ?? false;
  }

  @override
  Future<void> testConnection() async {
    try {
      print('Testing connection to: $baseUrl/test/');
      
      // First try a simple HEAD request which is faster
      try {
        final headResponse = await http.head(Uri.parse('$baseUrl/'))
            .timeout(const Duration(seconds: 5));
        
        if (headResponse.statusCode < 500) {
          // Server is up, but might return 404 for HEAD request
          return;
        }
      } catch (e) {
        // If HEAD fails, try GET
        print('HEAD request failed, trying GET: $e');
      }
      
      // Try a GET request to a test endpoint
      final response = await http.get(Uri.parse('$baseUrl/test/'))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        userId = data['user']['id'];
        userName = '${data['user']['first_name']} ${data['user']['last_name']}';
        isManager = data['user']['is_staff'] ?? false;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authToken!);
        await prefs.setInt('user_id', userId!);
        await prefs.setString('user_name', userName!);
        await prefs.setBool('is_manager', isManager!);
        
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
        Uri.parse('$baseUrl/auth/logout/'),
        headers: _headers,
      );
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _authToken = null;
      userId = null;
      userName = null;
      isManager = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('is_manager');
    }
  }

  // Employee methods
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
        Uri.parse('$baseUrl/employees/me/'),
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

  // Leave request methods
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
      final Map<String, dynamic> data = {
        'status': status,
      };
      
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

  // Task methods
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

  // Meeting methods
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
}
