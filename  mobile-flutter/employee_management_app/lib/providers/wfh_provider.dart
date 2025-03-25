import 'package:flutter/material.dart';
import '../models/wfh_request.dart';
import '../services/api_service.dart';

class WfhProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<WfhRequest> _wfhRequests = [];
  bool _isLoading = false;
  String? _error;

  List<WfhRequest> get wfhRequests => _wfhRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWfhRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wfhRequests = await _apiService.getWfhRequests();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch WFH requests: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitWfhRequest(WfhRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRequest = await _apiService.submitWfhRequest(request);
      _wfhRequests.add(newRequest);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit WFH request: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
