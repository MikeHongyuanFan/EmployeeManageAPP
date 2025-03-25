import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class WfhRequestsScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  final bool isManager;
  
  const WfhRequestsScreen({
    Key? key, 
    required this.apiService,
    this.isManager = false,
  }) : super(key: key);

  @override
  _WfhRequestsScreenState createState() => _WfhRequestsScreenState();
}

class _WfhRequestsScreenState extends State<WfhRequestsScreen> {
  List<WfhRequest>? _wfhRequests;
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
      final requests = await widget.apiService.getWfhRequests();
      
      setState(() {
        _wfhRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load WFH requests: ${e.toString()}';
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
        title: const Text('WFH Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateWfhRequestDialog(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _wfhRequests == null || _wfhRequests!.isEmpty
                  ? const Center(child: Text('No WFH requests found'))
                  : _buildRequestsList(),
    );
  }

  Widget _buildRequestsList() {
    // Group requests by status
    final pendingRequests = _wfhRequests!.where((req) => req.status == 'pending').toList();
    final approvedRequests = _wfhRequests!.where((req) => req.status == 'approved').toList();
    final rejectedRequests = _wfhRequests!.where((req) => req.status == 'rejected').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingRequests.isNotEmpty) ...[
            const Text(
              'Pending Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingRequests.map((request) => _buildWfhRequestCard(request)),
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
            ...approvedRequests.map((request) => _buildWfhRequestCard(request)),
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
            ...rejectedRequests.map((request) => _buildWfhRequestCard(request)),
          ],
        ],
      ),
    );
  }

  Widget _buildWfhRequestCard(WfhRequest request) {
    final Color statusColor = getStatusColor(request.status);
    
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
                  'WFH Request',
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
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Date: ${request.date}'),
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
                    onPressed: () => _cancelWfhRequest(request.id),
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

  Future<void> _showCreateWfhRequestDialog() async {
    final dateController = TextEditingController();
    final reasonController = TextEditingController();
    
    DateTime? selectedDate;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create WFH Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
                if (dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a date')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                await _createWfhRequest(
                  dateController.text,
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

  Future<void> _createWfhRequest(String date, String reason) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final data = {
        'date': date,
        'reason': reason,
      };
      
      await widget.apiService.createWfhRequest(data);
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WFH request created successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to create WFH request: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _cancelWfhRequest(int requestId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await widget.apiService.updateWfhRequestStatus(requestId, 'cancelled');
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WFH request cancelled')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to cancel WFH request: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
