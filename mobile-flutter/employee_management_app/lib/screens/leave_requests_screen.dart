import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class LeaveRequestsScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  
  const LeaveRequestsScreen({
    Key? key, 
    required this.apiService,
  }) : super(key: key);

  @override
  _LeaveRequestsScreenState createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  List<LeaveRequest>? _leaveRequests;
  Map<String, dynamic>? leaveBalance;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requests = await widget.apiService.getLeaveRequests();
      leaveBalance = await widget.apiService.getLeaveBalance();
      
      setState(() {
        _leaveRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load leave requests: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateLeaveRequestDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _leaveRequests == null || _leaveRequests!.isEmpty
                  ? const Center(child: Text('No leave requests found'))
                  : _buildRequestsList(),
    );
  }

  Widget _buildRequestsList() {
    // Group requests by status
    final pendingRequests = _leaveRequests!.where((req) => req.status == 'pending').toList();
    final approvedRequests = _leaveRequests!.where((req) => req.status == 'approved').toList();
    final rejectedRequests = _leaveRequests!.where((req) => req.status == 'rejected').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeaveBalanceCard(),
          const SizedBox(height: 16),
          if (pendingRequests.isNotEmpty) ...[
            const Text(
              'Pending Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingRequests.map((request) => _buildLeaveRequestCard(request)),
            const SizedBox(height: 24),
          ],
          if (approvedRequests.isNotEmpty) ...[
            const Text(
              'Approved Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...approvedRequests.map((request) => _buildLeaveRequestCard(request)),
            const SizedBox(height: 24),
          ],
          if (rejectedRequests.isNotEmpty) ...[
            const Text(
              'Rejected Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...rejectedRequests.map((request) => _buildLeaveRequestCard(request)),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceCard() {
    if (leaveBalance == null) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leave Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLeaveBalanceItem('Annual', leaveBalance!['annual'] ?? 0),
                _buildLeaveBalanceItem('Sick', leaveBalance!['sick'] ?? 0),
                _buildLeaveBalanceItem('Personal', leaveBalance!['personal'] ?? 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceItem(String type, int days) {
    return Column(
      children: [
        Text(
          days.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: days > 0 ? Colors.green : Colors.red,
          ),
        ),
        Text(
          type,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const Text(
          'days',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    final Color statusColor = LeaveRequest.getStatusColor(request.status);
    final IconData statusIcon = LeaveRequest.getStatusIcon(request.status);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.leaveType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('From: ${request.startDate}'),
            Text('To: ${request.endDate}'),
            if (request.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Reason: ${request.reason}'),
            ],
            if (request.status == 'rejected' && request.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Rejection Reason: ${request.rejectionReason}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (request.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _cancelLeaveRequest(request.id),
                    child: const Text('Cancel Request'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateLeaveRequestDialog() async {
    final leaveTypeController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final reasonController = TextEditingController();
    
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;
    
    final leaveTypes = ['Annual', 'Sick', 'Personal', 'Unpaid'];
    String selectedLeaveType = leaveTypes.first;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Leave Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedLeaveType,
                  decoration: const InputDecoration(
                    labelText: 'Leave Type',
                    border: OutlineInputBorder(),
                  ),
                  items: leaveTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedLeaveType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    
                    if (pickedDate != null) {
                      setState(() {
                        selectedStartDate = pickedDate;
                        startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: endDateController,
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    if (selectedStartDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a start date first')),
                      );
                      return;
                    }
                    
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedStartDate!,
                      firstDate: selectedStartDate!,
                      lastDate: selectedStartDate!.add(const Duration(days: 365)),
                    );
                    
                    if (pickedDate != null) {
                      setState(() {
                        selectedEndDate = pickedDate;
                        endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (startDateController.text.isEmpty || endDateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select both start and end dates')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                await _createLeaveRequest(
                  selectedLeaveType.toLowerCase(),
                  startDateController.text,
                  endDateController.text,
                  reasonController.text,
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createLeaveRequest(String leaveType, String startDate, String endDate, String reason) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final data = {
        'leave_type': leaveType,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      };
      
      await widget.apiService.createLeaveRequest(data);
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request created successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to create leave request: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _cancelLeaveRequest(int requestId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await widget.apiService.updateLeaveRequestStatus(requestId, 'cancelled');
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request cancelled')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to cancel leave request: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
