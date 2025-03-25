import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/status_chip.dart';

class WfhApprovalScreen extends StatefulWidget {
  const WfhApprovalScreen({Key? key}) : super(key: key);

  @override
  _WfhApprovalScreenState createState() => _WfhApprovalScreenState();
}

class _WfhApprovalScreenState extends State<WfhApprovalScreen> {
  final List<Map<String, dynamic>> _wfhRequests = [
    {
      'id': 1,
      'employee': 'Mary Johnson',
      'employee_id': 'EMP-23456',
      'date': DateTime(2025, 4, 15),
      'reason': 'Home internet installation',
      'status': 'pending',
      'avatar': 'MJ',
    },
    {
      'id': 2,
      'employee': 'Robert Smith',
      'employee_id': 'EMP-34567',
      'date': DateTime(2025, 4, 20),
      'reason': 'Personal appointment in the afternoon',
      'status': 'pending',
      'avatar': 'RS',
    },
    {
      'id': 3,
      'employee': 'John Doe',
      'employee_id': 'EMP-12345',
      'date': DateTime(2025, 4, 25),
      'reason': 'Car repair',
      'status': 'pending',
      'avatar': 'JD',
    },
    {
      'id': 4,
      'employee': 'Sarah Williams',
      'employee_id': 'EMP-45678',
      'date': DateTime(2025, 3, 20),
      'reason': 'Plumber visit',
      'status': 'approved',
      'avatar': 'SW',
    },
    {
      'id': 5,
      'employee': 'Michael Brown',
      'employee_id': 'EMP-56789',
      'date': DateTime(2025, 3, 15),
      'reason': 'Family emergency',
      'status': 'rejected',
      'avatar': 'MB',
    },
  ];

  String _selectedFilter = 'Pending';

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _selectedFilter == 'All'
        ? _wfhRequests
        : _wfhRequests.where((request) => request['status'].toString().toLowerCase() == _selectedFilter.toLowerCase()).toList();

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
              child: Text('No WFH requests found'),
            )
          : ListView.builder(
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                final date = DateFormat('MMM d, yyyy').format(request['date']);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(request['avatar'])),
                    title: Text('${request['employee']} - WFH Request'),
                    subtitle: Text(date),
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
                      _showWfhRequestDetails(request);
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

  void _showWfhRequestDetails(Map<String, dynamic> request) {
    final date = DateFormat('MMM d, yyyy').format(request['date']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${request['employee']} - WFH Request'),
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
                title: Text('Date: $date'),
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
      final index = _wfhRequests.indexWhere((request) => request['id'] == requestId);
      if (index != -1) {
        _wfhRequests[index]['status'] = 'approved';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WFH request approved')),
    );
  }

  void _rejectRequest(int requestId) {
    setState(() {
      final index = _wfhRequests.indexWhere((request) => request['id'] == requestId);
      if (index != -1) {
        _wfhRequests[index]['status'] = 'rejected';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WFH request rejected')),
    );
  }
}
