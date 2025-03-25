import 'package:flutter/material.dart';
import '../models/leave_request.dart';
import '../models/leave_balance.dart';
import '../services/api_service.dart';

class LeaveProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<LeaveRequest> _leaveRequests = [];
  LeaveBalance? _leaveBalance;
  bool _isLoading = false;
  String? _error;

  List<LeaveRequest> get leaveRequests => _leaveRequests;
  LeaveBalance? get leaveBalance => _leaveBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLeaveRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaveRequests = await _apiService.getLeaveRequests();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch leave requests: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeaveBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaveBalance = await _apiService.getLeaveBalance();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch leave balance: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitLeaveRequest(LeaveRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRequest = await _apiService.submitLeaveRequest(request);
      _leaveRequests.add(newRequest);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit leave request: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
