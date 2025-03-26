import '../models/models.dart';

/// Interface for API services
abstract class ApiServiceInterface {
  String? get authToken;
  set authToken(String? value);
  int? userId;
  String? userName;
  bool? isManager;

  Future<void> initFromPrefs();
  Future<void> testConnection();
  Future<Map<String, dynamic>> login(String username, String password);
  Future<void> logout();

  // Employee methods
  Future<List<Employee>> getEmployees();
  Future<Employee> getEmployee(int id);
  Future<Employee> getCurrentEmployee();
  Future<Employee> getEmployeeProfile();
  Future<User> getUserProfile();

  // Task methods
  Future<List<Task>> getTasks();
  Future<Task> getTask(int id);
  Future<Task> createTask(Map<String, dynamic> data);
  Future<Task> updateTask(int taskId, Map<String, dynamic> data);

  // Meeting methods
  Future<List<Meeting>> getMeetings();
  Future<Meeting> getMeeting(int id);
  Future<Meeting> createMeeting(Map<String, dynamic> data);
  Future<Meeting> updateMeeting(int meetingId, Map<String, dynamic> data);

  // Leave request methods
  Future<List<LeaveRequest>> getLeaveRequests();
  Future<LeaveRequest> createLeaveRequest(Map<String, dynamic> data);
  Future<LeaveRequest> updateLeaveRequestStatus(int requestId, String status, {String? reason});
  Future<Map<String, int>> getLeaveBalance();

  // Working time methods
  Future<List<WorkingTime>> getWorkingTimes();
  Future<WorkingTime> clockIn({String? notes});
  Future<WorkingTime> clockOut({String? notes});
  Future<List<WorkingTime>> getWorkingHours();
  Future<WorkingTime> logWorkingHours(Map<String, dynamic> data);
  
  // WFH requests methods
  Future<List<WfhRequest>> getWfhRequests();
  Future<WfhRequest> createWfhRequest(Map<String, dynamic> data);
  Future<WfhRequest> updateWfhRequestStatus(int requestId, String status, {String? reason});
  
  // Document methods
  Future<List<Document>> getDocuments();
  Future<String> getDocumentDownloadUrl(int documentId);
  Future<Document> shareDocument(int documentId, List<int> employeeIds);
  Future<void> deleteDocument(int documentId);
  Future<Document> updateDocument(int documentId, Map<String, dynamic> data);
  Future<Document> uploadDocument(Map<String, dynamic> data);
}
