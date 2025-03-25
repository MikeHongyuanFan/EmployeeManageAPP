import 'package:flutter/material.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class WfhApprovalScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  
  const WfhApprovalScreen({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  _WfhApprovalScreenState createState() => _WfhApprovalScreenState();
}

class _WfhApprovalScreenState extends State<WfhApprovalScreen> {
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
      final wfhRequests = await widget.apiService.getWfhRequests();
      
      setState(() {
        _wfhRequests = wfhRequests;
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
        title: const Text('WFH Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
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
    final pendingRequests = _wfhRequests!.where((req) => req.status.toLowerCase() == 'pending').toList();
    final approvedRequests = _wfhRequests!.where((req) => req.status.toLowerCase() == 'approved').toList();
    final rejectedRequests = _wfhRequests!.where((req) => req.status.toLowerCase() == 'rejected').toList();
    
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
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingRequests.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => _buildRequestItem(pendingRequests[index]),
              ),
            ),
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
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: approvedRequests.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => _buildRequestItem(approvedRequests[index], showActions: false),
              ),
            ),
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
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rejectedRequests.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => _buildRequestItem(rejectedRequests[index], showActions: false),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestItem(WfhRequest request, {bool showActions = true}) {
    return ListTile(
      title: Text(request.userName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date: ${request.date}'),
          if (request.reason.isNotEmpty) Text('Reason: ${request.reason}'),
          if (request.status.toLowerCase() == 'rejected' && request.rejectionReason != null)
            Text('Rejection Reason: ${request.rejectionReason}'),
        ],
      ),
      trailing: showActions
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _handleApproval(request.id, 'approved'),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _showRejectionReasonDialog(
                    (reason) => _handleApproval(request.id, 'rejected', reason: reason),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _handleApproval(int requestId, String status, {String? reason}) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Call the API to update the status
      await widget.apiService.updateWfhRequestStatus(
        requestId,
        status,
        reason: reason,
      );
      
      // Refresh the data
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WFH request ${status.toUpperCase()}')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to update WFH request: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _showRejectionReasonDialog(Function(String) onSubmit) async {
    final reasonController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }
              Navigator.of(context).pop();
              onSubmit(reasonController.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
