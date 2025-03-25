import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/leave_request.dart';
import '../models/wfh_request.dart';
import '../models/task.dart';
import '../models/meeting.dart';
import '../models/document.dart';
import '../models/leave_balance.dart';

class ApiService {
  // Django backend URL with custom port
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For iOS simulator, localhost should work fine
  static const String baseUrl = 'http://localhost:8000/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get auth token from secure storage
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Set auth token in secure storage
  Future<void> _setToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Clear auth token from secure storage
  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // Create headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    };
  }

  // Login user and get token
  Future<bool> login(String username, String password) async {
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
      await _setToken(data['token']);
      return true;
    }
    return false;
  }

  // Get user profile
  Future<User> getUserProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // Get leave requests
  Future<List<LeaveRequest>> getLeaveRequests() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/leave-requests/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LeaveRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load leave requests');
    }
  }

  // Submit leave request
  Future<LeaveRequest> submitLeaveRequest(LeaveRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/leave-requests/'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return LeaveRequest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to submit leave request');
    }
  }

  // Get WFH requests
  Future<List<WfhRequest>> getWfhRequests() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/wfh-requests/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WfhRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load WFH requests');
    }
  }

  // Submit WFH request
  Future<WfhRequest> submitWfhRequest(WfhRequest request) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/wfh-requests/'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return WfhRequest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to submit WFH request');
    }
  }

  // Get leave balance
  Future<LeaveBalance> getLeaveBalance() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/leave-balance/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return LeaveBalance.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load leave balance');
    }
  }

  // Get tasks
  Future<List<Task>> getTasks() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Create task
  Future<Task> createTask(Task task) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  // Update task
  Future<Task> updateTask(int taskId, Task task) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/tasks/$taskId/'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  // Log working hours
  Future<void> logWorkingHours(DateTime startTime, String workType) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/working-hours/'),
      headers: headers,
      body: jsonEncode({
        'start_time': startTime.toIso8601String(),
        'work_type': workType, // 'office' or 'wfh'
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to log working hours');
    }
  }

  // Get meetings
  Future<List<Meeting>> getMeetings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/meetings/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Meeting.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  // Get documents
  Future<List<Document>> getDocuments() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/documents/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Document.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  // Upload document
  Future<Document> uploadDocument(String title, String filePath, bool isShared) async {
    final headers = await _getHeaders();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/documents/'),
    );

    // Add auth token to headers
    final token = await _getToken();
    request.headers['Authorization'] = 'Token $token';

    // Add form fields
    request.fields['title'] = title;
    request.fields['is_shared'] = isShared.toString();

    // Add file
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    // Send request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Document.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload document');
    }
  }

  // Get notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
