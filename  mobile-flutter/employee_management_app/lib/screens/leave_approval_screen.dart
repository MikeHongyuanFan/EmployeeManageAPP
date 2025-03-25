import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/status_chip.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({Key? key}) : super(key: key);

  @override
  _LeaveApprovalScreenState createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  final List<Map<String, dynamic>> _leaveRequests = [
    {
      'id': 1,
      'employee': 'John Doe',
      'employee_id': 'EMP-12345',
      'type': 'Annual Leave',
      'start_date': DateTime(2025, 5, 10),
      'end_date': DateTime(2025, 5, 12),
      'reason': 'Family vacation',
      'status': 'pending',
      'days': 3,
      'avatar': 'JD',
    },
    {
      'id': 2,
      'employee': 'Mary Johnson',
      'employee_id': 'EMP-23456',
      'type': 'Sick Leave',
      'start_date': DateTime(2025, 4, 5),
      'end_date': DateTime(2025, 4, 6),
      'reason': 'Flu',
      'status': 'pending',
      'days': 2,
      'avatar': 'MJ',
    },
    {
      'id': 3,
      'employee': 'Robert Smith',
      'employee_id': 'EMP-34567',
      'type': 'Personal Leave',
      'start_date': DateTime(2025, 4, 15),
      'end_date': DateTime(2025, 4, 15),
      'reason': 'Doctor appointment',
      'status': 'pending',
      'days': 1,
      'avatar': 'RS',
    },
    {
      'id': 4,
      'employee': 'Sarah Williams',
      'employee_id': 'EMP-45678',
      'type': 'Annual Leave',
      'start_date': DateTime(2025, 3, 20),
      'end_date': DateTime(2025, 3, 24),
      'reason': 'Family event',
      'status': 'approved',
      'days': 5,
      'avatar': 'SW',
    },
    {
      'id': 5,
      'employee': 'Michael Brown',
      'employee_id': 'EMP-56789',
      'type': 'Sick Leave',
      'start_date': DateTime(2025, 3, 15),
      'end_date': DateTime(2025, 3, 16),
      'reason': 'Cold',
      'status': 'rejected',
      'days': 2,
      'avatar': 'MB',
    },
  ];

  String _selectedFilter = 'Pending';

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _selectedFilter == 'All'
        ? _leaveRequests
        : _leaveRequests.where((request) => request['status'].toString().toLowerCase() == _selectedFilter.toLowerCase()).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Approved'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rejected'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredRequests.isEmpty
          ? const Center(
              child: Text('No leave requests found'),
            )
          : ListView.builder(
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                final startDate = DateFormat('MMM d, yyyy').format(request['start_date']);
                final endDate = DateFormat('MMM d, yyyy').format(request['end_date']);
                final dateRange = startDate == endDate
                    ? startDate
                    : '$startDate - $endDate';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(request['avatar'])),
                    title: Text('${request['employee']} - ${request['type']}'),
                    subtitle: Text(dateRange),
                    trailing: request['status'] == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  _approveRequest(request['id']);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _rejectRequest(request['id']);
                                },
                              ),
                            ],
                          )
                        : StatusChip(status: request['status']),
                    onTap: () {
                      _showLeaveRequestDetails(request);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }

  void _showLeaveRequestDetails(Map<String, dynamic> request) {
    final startDate = DateFormat('MMM d, yyyy').format(request['start_date']);
    final endDate = DateFormat('MMM d, yyyy').format(request['end_date']);
    final dateRange = startDate == endDate
        ? startDate
        : '$startDate - $endDate';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${request['employee']} - ${request['type']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Employee ID: ${request['employee_id']}'),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text('Date: $dateRange'),
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: Text('Duration: ${request['days']} day(s)'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: Text('Reason: ${request['reason']}'),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Row(
                  children: [
                    const Text('Status: '),
                    StatusChip(status: request['status']),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            if (request['status'] == 'pending')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _rejectRequest(request['id']);
                    },
                    child: const Text('Reject'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _approveRequest(request['id']);
                    },
                    child: const Text('Approve'),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  void _approveRequest(int requestId) {
    setState(() {
      final index = _leaveRequests.indexWhere((request) => request['id'] == requestId);
      if (index != -1) {
        _leaveRequests[index]['status'] = 'approved';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request approved')),
    );
  }

  void _rejectRequest(int requestId) {
    setState(() {
      final index = _leaveRequests.indexWhere((request) => request['id'] == requestId);
      if (index != -1) {
        _leaveRequests[index]['status'] = 'rejected';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request rejected')),
    );
  }
}
