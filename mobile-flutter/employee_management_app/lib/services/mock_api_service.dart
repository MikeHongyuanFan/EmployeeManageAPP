import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service_interface.dart';

/// A mock API service that implements the ApiServiceInterface
/// This allows the app to function without a backend server
class MockApiService implements ApiServiceInterface {
  // Additional methods required by the interface
  @override
  Future<WfhRequest> createWfhRequest(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 800));
    final newRequest = WfhRequest(
      id: _wfhRequests.length + 1,
      userId: userId!,
      userName: userName!,
      date: data['date'] ?? data['start_date'],
      reason: data['reason'] ?? '',
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _wfhRequests.add(newRequest);
    return newRequest;
  }
  
  @override
  Future<void> deleteDocument(int documentId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return;
  }
  
  @override
  Future<String> getDocumentDownloadUrl(int documentId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return 'https://example.com/documents/$documentId';
  }
  
  @override
  Future<List<Document>> getDocuments() async {
    await Future.delayed(Duration(milliseconds: 800));
    return [
      Document(
        id: 1,
        title: 'Employee Handbook',
        fileName: 'handbook.pdf',
        description: 'Company handbook for employees',
        fileUrl: 'https://example.com/documents/1',
        uploadedById: 2,
        uploadedByName: 'Jane Smith',
        sharedWith: [1, 2],
        sharedWithNames: ['John Doe', 'Jane Smith'],
        createdAt: '2025-03-15T10:00:00Z',
        updatedAt: '2025-03-15T10:00:00Z',
      ),
      Document(
        id: 2,
        title: 'Company Policies',
        fileName: 'policies.pdf',
        description: 'Official company policies',
        fileUrl: 'https://example.com/documents/2',
        uploadedById: 2,
        uploadedByName: 'Jane Smith',
        sharedWith: [1],
        sharedWithNames: ['John Doe'],
        createdAt: '2025-03-16T11:30:00Z',
        updatedAt: '2025-03-16T11:30:00Z',
      ),
    ];
  }
  
  @override
  Future<Document> shareDocument(int documentId, List<int> employeeIds) async {
    await Future.delayed(Duration(milliseconds: 800));
    return Document(
      id: documentId,
      title: 'Shared Document',
      fileName: 'document.pdf',
      description: 'A shared document',
      fileUrl: 'https://example.com/documents/$documentId',
      uploadedById: 2,
      uploadedByName: 'Jane Smith',
      sharedWith: employeeIds,
      sharedWithNames: employeeIds.map((id) => id == 1 ? 'John Doe' : 'Jane Smith').toList(),
      createdAt: '2025-03-20T09:00:00Z',
      updatedAt: DateTime.now().toIso8601String(),
    );
  }
  
  @override
  Future<bool> testConnection() async {
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }
  
  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(Duration(milliseconds: 1000));
    
    if (username == 'employee' && password == 'password123') {
      _authToken = 'mock_token_employee';
      userId = 1;
      userName = 'John Doe';
      isManager = false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _authToken!);
      await prefs.setInt('user_id', userId!);
      await prefs.setString('user_name', userName!);
      await prefs.setBool('is_manager', isManager!);
      
      return {
        'token': _authToken,
        'user': {
          'id': userId,
          'first_name': 'John',
          'last_name': 'Doe',
          'is_staff': false,
        }
      };
    } else if (username == 'manager' && password == 'password123') {
      _authToken = 'mock_token_manager';
      userId = 2;
      userName = 'Jane Smith';
      isManager = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _authToken!);
      await prefs.setInt('user_id', userId!);
      await prefs.setString('user_name', userName!);
      await prefs.setBool('is_manager', isManager!);
      
      return {
        'token': _authToken,
        'user': {
          'id': userId,
          'first_name': 'Jane',
          'last_name': 'Smith',
          'is_staff': true,
        }
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<void> logout() async {
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

  // Employee methods
  @override
  Future<List<Employee>> getEmployees() async {
    await Future.delayed(Duration(milliseconds: 800));
    return _employees;
  }

  @override
  Future<Employee> getEmployee(int id) async {
    await Future.delayed(Duration(milliseconds: 500));
    final employee = _employees.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Employee not found'),
    );
    return employee;
  }

  @override
  Future<Employee> getCurrentEmployee() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (userId == null) {
      throw Exception('Not logged in');
    }
    
    final employee = _employees.firstWhere(
      (e) => e.userId == userId,
      orElse: () => throw Exception('Employee not found'),
    );
    return employee;
  }

  @override
  Future<Employee> getEmployeeProfile() async {
    return getCurrentEmployee();
  }

  @override
  Future<User> getUserProfile() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (userId == null) {
      throw Exception('Not logged in');
    }
    
    return User(
      id: userId!,
      username: isManager! ? 'manager' : 'employee',
      firstName: isManager! ? 'Jane' : 'John',
      lastName: isManager! ? 'Smith' : 'Doe',
      email: isManager! ? 'manager@example.com' : 'employee@example.com',
      isStaff: isManager!,
      isActive: true,
      dateJoined: '2023-01-01T00:00:00Z',
      lastLogin: DateTime.now().toIso8601String(),
    );
  }

  // Task methods
  @override
  Future<List<Task>> getTasks() async {
    await Future.delayed(Duration(milliseconds: 800));
    if (isManager == true) {
      return _tasks;
    } else {
      return _tasks.where((task) => task.assignedToId == userId).toList();
    }
  }

  @override
  Future<Task> getTask(int id) async {
    await Future.delayed(Duration(milliseconds: 500));
    final task = _tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('Task not found'),
    );
    return task;
  }

  @override
  Future<Task> createTask(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 800));
    final newTask = Task(
      id: _tasks.length + 1,
      title: data['title'],
      description: data['description'] ?? '',
      assignedById: userId!,
      assignedByName: userName!,
      assignedToId: data['assigned_to_id'],
      assignedToName: data['assigned_to_name'] ?? 'Unknown',
      dueDate: data['due_date'],
      priority: data['priority'] ?? 'medium',
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<Task> updateTask(int taskId, Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 800));
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final task = _tasks[index];
      _tasks[index] = Task(
        id: task.id,
        title: data['title'] ?? task.title,
        description: data['description'] ?? task.description,
        assignedById: task.assignedById,
        assignedByName: task.assignedByName,
        assignedToId: data['assigned_to_id'] ?? task.assignedToId,
        assignedToName: data['assigned_to_name'] ?? task.assignedToName,
        dueDate: data['due_date'] ?? task.dueDate,
        priority: data['priority'] ?? task.priority,
        status: data['status'] ?? task.status,
        createdAt: task.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      return _tasks[index];
    } else {
      throw Exception('Task not found');
    }
  }

  // Meeting methods
  @override
  Future<List<Meeting>> getMeetings() async {
    await Future.delayed(Duration(milliseconds: 800));
    if (isManager == true) {
      return _meetings;
    } else {
      return _meetings.where((meeting) => meeting.attendees.contains(userId)).toList();
    }
  }

  @override
  Future<Meeting> getMeeting(int id) async {
    await Future.delayed(Duration(milliseconds: 500));
    final meeting = _meetings.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception('Meeting not found'),
    );
    return meeting;
  }

  @override
  Future<Meeting> createMeeting(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 800));
    final newMeeting = Meeting(
      id: _meetings.length + 1,
      title: data['title'],
      description: data['description'] ?? '',
      date: data['date'],
      startTime: data['start_time'],
      endTime: data['end_time'],
      location: data['location'] ?? '',
      organizedById: userId!,
      organizedByName: userName!,
      attendees: List<int>.from(data['attendees'] ?? []),
      attendeeNames: List<String>.from(data['attendee_names'] ?? []),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _meetings.add(newMeeting);
    return newMeeting;
  }

  @override
  Future<Meeting> updateMeeting(int meetingId, Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 800));
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index >= 0) {
      final meeting = _meetings[index];
      
      // Check if this is a delete operation
      if (data['delete'] == true) {
        _meetings.removeAt(index);
        return meeting;
      }
      
      _meetings[index] = Meeting(
        id: meeting.id,
        title: data['title'] ?? meeting.title,
        description: data['description'] ?? meeting.description,
        date: data['date'] ?? meeting.date,
        startTime: data['start_time'] ?? meeting.startTime,
        endTime: data['end_time'] ?? meeting.endTime,
        location: data['location'] ?? meeting.location,
        organizedById: meeting.organizedById,
        organizedByName: meeting.organizedByName,
        attendees: data['attendees'] != null 
            ? List<int>.from(data['attendees']) 
            : meeting.attendees,
        attendeeNames: data['attendee_names'] != null 
            ? List<String>.from(data['attendee_names']) 
            : meeting.attendeeNames,
        createdAt: meeting.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      return _meetings[index];
    } else {
      throw Exception('Meeting not found');
    }
  }

  // Leave request methods
  @override
  Future<List<LeaveRequest>> getLeaveRequests() async {
    await Future.delayed(Duration(milliseconds: 800));
    if (isManager == true) {
      return _leaveRequests;
    } else {
      return _leaveRequests.where((leave) => leave.userId == userId).toList();
    }
  }

  @override
  Future<LeaveRequest> createLeaveRequest(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 800));
    final newRequest = LeaveRequest(
      id: _leaveRequests.length + 1,
      userId: userId!,
      userName: userName!,
      leaveType: data['leave_type'],
      startDate: data['start_date'],
      endDate: data['end_date'],
      reason: data['reason'] ?? '',
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _leaveRequests.add(newRequest);
    return newRequest;
  }

  @override
  Future<LeaveRequest> updateLeaveRequestStatus(int requestId, String status, {String? reason}) async {
    await Future.delayed(Duration(milliseconds: 800));
    final index = _leaveRequests.indexWhere((r) => r.id == requestId);
    if (index >= 0) {
      _leaveRequests[index] = LeaveRequest(
        id: _leaveRequests[index].id,
        userId: _leaveRequests[index].userId,
        userName: _leaveRequests[index].userName,
        leaveType: _leaveRequests[index].leaveType,
        startDate: _leaveRequests[index].startDate,
        endDate: _leaveRequests[index].endDate,
        reason: _leaveRequests[index].reason,
        status: status.toLowerCase(),
        rejectionReason: reason ?? (status.toLowerCase() == 'rejected' ? 'Rejected by manager' : null),
        createdAt: _leaveRequests[index].createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      return _leaveRequests[index];
    } else {
      throw Exception('Leave request not found');
    }
  }

  @override
  Future<Map<String, int>> getLeaveBalance() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (userId == null) {
      throw Exception('Not logged in');
    }
    
    final employee = _employees.firstWhere(
      (e) => e.userId == userId,
      orElse: () => throw Exception('Employee not found'),
    );
    
    return employee.leaveBalance;
  }

  // Working time methods
  @override
  Future<List<WorkingTime>> getWorkingTimes() async {
    await Future.delayed(Duration(milliseconds: 800));
    if (isManager == true) {
      return _workingTimes;
    } else {
      return _workingTimes.where((wt) => wt.userId == userId).toList();
    }
  }

  @override
  Future<WorkingTime> clockIn({String? notes}) async {
    await Future.delayed(Duration(milliseconds: 800));
    final now = DateTime.now();
    final today = now.toString().split(' ')[0]; // YYYY-MM-DD
    
    // Check if already clocked in today
    final existingIndex = _workingTimes.indexWhere(
      (wt) => wt.userId == userId && wt.date == today
    );
    
    if (existingIndex >= 0) {
      throw Exception('Already clocked in today');
    }
    
    final clockInTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final newWorkingTime = WorkingTime(
      id: _workingTimes.length + 1,
      userId: userId!,
      userName: userName!,
      date: today,
      clockIn: clockInTime,
      notes: notes,
      workType: 'office',
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
    
    _workingTimes.add(newWorkingTime);
    return newWorkingTime;
  }

  @override
  Future<WorkingTime> clockOut({String? notes}) async {
    await Future.delayed(Duration(milliseconds: 800));
    final now = DateTime.now();
    final today = now.toString().split(' ')[0]; // YYYY-MM-DD
    
    // Find today's clock-in
    final index = _workingTimes.indexWhere(
      (wt) => wt.userId == userId && wt.date == today && wt.clockOut == null
    );
    
    if (index < 0) {
      throw Exception('No active clock-in found for today');
    }
    
    // Calculate hours worked
    final clockInTime = _workingTimes[index].clockIn.split(':');
    final clockInHour = int.parse(clockInTime[0]);
    final clockInMinute = int.parse(clockInTime[1]);
    
    final clockOutTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final totalMinutes = (now.hour - clockInHour) * 60 + (now.minute - clockInMinute);
    
    _workingTimes[index] = WorkingTime(
      id: _workingTimes[index].id,
      userId: _workingTimes[index].userId,
      userName: _workingTimes[index].userName,
      date: _workingTimes[index].date,
      clockIn: _workingTimes[index].clockIn,
      clockOut: clockOutTime,
      totalMinutes: totalMinutes,
      notes: notes ?? _workingTimes[index].notes,
      workType: _workingTimes[index].workType,
      createdAt: _workingTimes[index].createdAt,
      updatedAt: now.toIso8601String(),
    );
    
    return _workingTimes[index];
  }

  @override
  Future<List<WorkingTime>> getWorkingHours() async {
    return getWorkingTimes();
  }

  @override
  Future<WorkingTime> logWorkingHours(Map<String, dynamic> data) async {
    await Future.delayed(Duration(milliseconds: 800));
    final newWorkingTime = WorkingTime(
      id: _workingTimes.length + 1,
      userId: userId!,
      userName: userName!,
      date: data['date'],
      clockIn: data['clock_in'],
      clockOut: data['clock_out'],
      totalMinutes: data['total_minutes'],
      notes: data['notes'],
      workType: data['work_type'] ?? 'office',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    
    _workingTimes.add(newWorkingTime);
    return newWorkingTime;
  }

  // WFH requests methods
  @override
  Future<List<WfhRequest>> getWfhRequests() async {
    await Future.delayed(Duration(milliseconds: 800));
    if (isManager == true) {
      return _wfhRequests;
    } else {
      return _wfhRequests.where((wfh) => wfh.userId == userId).toList();
    }
  }

  @override
  Future<WfhRequest> updateWfhRequestStatus(int requestId, String status, {String? reason}) async {
    await Future.delayed(Duration(milliseconds: 800));
    final index = _wfhRequests.indexWhere((r) => r.id == requestId);
    if (index >= 0) {
      _wfhRequests[index] = WfhRequest(
        id: _wfhRequests[index].id,
        userId: _wfhRequests[index].userId,
        userName: _wfhRequests[index].userName,
        date: _wfhRequests[index].date,
        reason: _wfhRequests[index].reason,
        status: status.toLowerCase(),
        rejectionReason: reason ?? (status.toLowerCase() == 'rejected' ? 'Rejected by manager' : null),
        createdAt: _wfhRequests[index].createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      return _wfhRequests[index];
    } else {
      throw Exception('WFH request not found');
    }
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

  // Mock data
  final List<Employee> _employees = [
    Employee(
      id: 1,
      userId: 1,
      firstName: 'John',
      lastName: 'Doe',
      email: 'employee@example.com',
      employeeId: 'EMP001',
      position: 'Developer',
      departmentName: 'Engineering',
      joinDate: '2023-01-15',
      leaveBalance: {'annual': 15, 'sick': 10, 'personal': 5},
      isActive: true,
      phone: '555-1234',
      address: '123 Main St',
    ),
    Employee(
      id: 2,
      userId: 2,
      firstName: 'Jane',
      lastName: 'Smith',
      email: 'manager@example.com',
      employeeId: 'EMP002',
      position: 'Team Lead',
      departmentName: 'Engineering',
      joinDate: '2022-06-10',
      leaveBalance: {'annual': 20, 'sick': 10, 'personal': 5},
      isActive: true,
      phone: '555-5678',
      address: '456 Oak St',
      managerName: 'Director',
    ),
  ];

  final List<Task> _tasks = [
    Task(
      id: 1,
      title: 'Implement login screen',
      description: 'Create a login screen with username and password fields',
      assignedById: 2,
      assignedByName: 'Jane Smith',
      assignedToId: 1,
      assignedToName: 'John Doe',
      dueDate: '2025-03-25',
      priority: 'high',
      status: 'in_progress',
      createdAt: '2025-03-20T08:00:00Z',
      updatedAt: '2025-03-20T08:00:00Z',
    ),
    Task(
      id: 2,
      title: 'Fix navigation bug',
      description: 'Fix the bug in the navigation drawer',
      assignedById: 2,
      assignedByName: 'Jane Smith',
      assignedToId: 1,
      assignedToName: 'John Doe',
      dueDate: '2025-03-26',
      priority: 'medium',
      status: 'pending',
      createdAt: '2025-03-20T09:00:00Z',
      updatedAt: '2025-03-20T09:00:00Z',
    ),
  ];

  final List<Meeting> _meetings = [
    Meeting(
      id: 1,
      title: 'Sprint Planning',
      description: 'Plan tasks for the next sprint',
      date: '2025-03-26',
      startTime: '10:00',
      endTime: '11:00',
      location: 'Conference Room A',
      organizedById: 2,
      organizedByName: 'Jane Smith',
      attendees: [1, 2],
      attendeeNames: ['John Doe', 'Jane Smith'],
      createdAt: '2025-03-20T09:00:00Z',
      updatedAt: '2025-03-20T09:00:00Z',
    ),
    Meeting(
      id: 2,
      title: 'Code Review',
      description: 'Review pull requests and discuss code quality',
      date: '2025-03-27',
      startTime: '14:00',
      endTime: '15:00',
      location: 'Conference Room B',
      organizedById: 2,
      organizedByName: 'Jane Smith',
      attendees: [1, 2],
      attendeeNames: ['John Doe', 'Jane Smith'],
      createdAt: '2025-03-20T09:30:00Z',
      updatedAt: '2025-03-20T09:30:00Z',
    ),
  ];

  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 1,
      userId: 1,
      userName: 'John Doe',
      leaveType: 'Annual Leave',
      startDate: '2025-03-30',
      endDate: '2025-04-01',
      reason: 'Family vacation',
      status: 'pending',
      createdAt: '2025-03-20T08:00:00Z',
      updatedAt: '2025-03-20T08:00:00Z',
    ),
  ];

  final List<WfhRequest> _wfhRequests = [
    WfhRequest(
      id: 1,
      userId: 1,
      userName: 'John Doe',
      date: '2025-03-28',
      reason: 'Home office setup',
      status: 'pending',
      createdAt: '2025-03-20T10:00:00Z',
      updatedAt: '2025-03-20T10:00:00Z',
    ),
  ];

  final List<WorkingTime> _workingTimes = [
    WorkingTime(
      id: 1,
      userId: 1,
      userName: 'John Doe',
      date: '2025-03-24',
      clockIn: '09:00',
      clockOut: '17:30',
      totalMinutes: 510, // 8.5 hours
      workType: 'office',
      createdAt: '2025-03-24T09:00:00Z',
      updatedAt: '2025-03-24T17:30:00Z',
    ),
  ];

  @override
  Future<void> initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    userId = prefs.getInt('user_id');
    userName = prefs.getString('user_name');
    isManager = prefs.getBool('is_manager');
  }
}
