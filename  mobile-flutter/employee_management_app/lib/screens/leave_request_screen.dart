import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/status_chip.dart';
import '../utils/constants.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({Key? key}) : super(key: key);

  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final List<Map<String, dynamic>> _leaveRequests = [
    {
      'id': 1,
      'type': 'Annual Leave',
      'start_date': DateTime(2025, 5, 10),
      'end_date': DateTime(2025, 5, 12),
      'reason': 'Family vacation',
      'status': 'pending',
    },
    {
      'id': 2,
      'type': 'Sick Leave',
      'start_date': DateTime(2025, 3, 5),
      'end_date': DateTime(2025, 3, 6),
      'reason': 'Flu',
      'status': 'approved',
    },
    {
      'id': 3,
      'type': 'Personal Leave',
      'start_date': DateTime(2025, 2, 15),
      'end_date': DateTime(2025, 2, 15),
      'reason': 'Doctor appointment',
      'status': 'rejected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _leaveRequests.isEmpty
          ? const Center(
              child: Text('No leave requests found'),
            )
          : ListView.builder(
              itemCount: _leaveRequests.length,
              itemBuilder: (context, index) {
                final request = _leaveRequests[index];
                final startDate = DateFormat('MMM d, yyyy').format(request['start_date']);
                final endDate = DateFormat('MMM d, yyyy').format(request['end_date']);
                final dateRange = startDate == endDate
                    ? startDate
                    : '$startDate - $endDate';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(request['type']),
                    subtitle: Text(dateRange),
                    trailing: StatusChip(status: request['status']),
                    onTap: () {
                      _showLeaveRequestDetails(request);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLeaveRequestDialog();
        },
        child: const Icon(Icons.add),
      ),
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
          title: Text(request['type']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text(dateRange),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(request['reason']),
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Show cancel confirmation dialog
                  _showCancelConfirmationDialog(request['id']);
                },
                child: const Text('Cancel Request'),
              ),
          ],
        );
      },
    );
  }

  void _showCancelConfirmationDialog(int requestId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Leave Request'),
          content: const Text('Are you sure you want to cancel this leave request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Cancel the leave request
                setState(() {
                  _leaveRequests.removeWhere((request) => request['id'] == requestId);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave request cancelled')),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showAddLeaveRequestDialog() {
    final _formKey = GlobalKey<FormState>();
    String _selectedLeaveType = Constants.leaveTypes[0];
    DateTime _startDate = DateTime.now();
    DateTime _endDate = DateTime.now();
    final _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Leave Request'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedLeaveType,
                    decoration: const InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(),
                    ),
                    items: Constants.leaveTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _selectedLeaveType = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_startDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                          if (_endDate.isBefore(_startDate)) {
                            _endDate = _startDate;
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_endDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime(2026),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reason';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  // Add new leave request
                  setState(() {
                    _leaveRequests.add({
                      'id': _leaveRequests.length + 1,
                      'type': _selectedLeaveType,
                      'start_date': _startDate,
                      'end_date': _endDate,
                      'reason': _reasonController.text,
                      'status': 'pending',
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leave request submitted')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
