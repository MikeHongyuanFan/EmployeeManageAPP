import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/status_chip.dart';

class WfhRequestScreen extends StatefulWidget {
  const WfhRequestScreen({Key? key}) : super(key: key);

  @override
  _WfhRequestScreenState createState() => _WfhRequestScreenState();
}

class _WfhRequestScreenState extends State<WfhRequestScreen> {
  final List<Map<String, dynamic>> _wfhRequests = [
    {
      'id': 1,
      'date': DateTime(2025, 4, 15),
      'reason': 'Home internet installation',
      'status': 'pending',
    },
    {
      'id': 2,
      'date': DateTime(2025, 3, 20),
      'reason': 'Personal appointment in the afternoon',
      'status': 'approved',
    },
    {
      'id': 3,
      'date': DateTime(2025, 2, 10),
      'reason': 'Car repair',
      'status': 'rejected',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _wfhRequests.isEmpty
          ? const Center(
              child: Text('No WFH requests found'),
            )
          : ListView.builder(
              itemCount: _wfhRequests.length,
              itemBuilder: (context, index) {
                final request = _wfhRequests[index];
                final date = DateFormat('MMM d, yyyy').format(request['date']);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('WFH Request'),
                    subtitle: Text(date),
                    trailing: StatusChip(status: request['status']),
                    onTap: () {
                      _showWfhRequestDetails(request);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWfhRequestDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showWfhRequestDetails(Map<String, dynamic> request) {
    final date = DateFormat('MMM d, yyyy').format(request['date']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('WFH Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text(date),
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
          title: const Text('Cancel WFH Request'),
          content: const Text('Are you sure you want to cancel this WFH request?'),
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
                // Cancel the WFH request
                setState(() {
                  _wfhRequests.removeWhere((request) => request['id'] == requestId);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('WFH request cancelled')),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showAddWfhRequestDialog() {
    final _formKey = GlobalKey<FormState>();
    DateTime _selectedDate = DateTime.now();
    final _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New WFH Request'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
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
                  // Add new WFH request
                  setState(() {
                    _wfhRequests.add({
                      'id': _wfhRequests.length + 1,
                      'date': _selectedDate,
                      'reason': _reasonController.text,
                      'status': 'pending',
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WFH request submitted')),
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
