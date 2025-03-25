import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class DocumentShareScreen extends StatefulWidget {
  final ApiService apiService;
  final Document document;
  
  const DocumentShareScreen({
    Key? key,
    required this.apiService,
    required this.document,
  }) : super(key: key);

  @override
  _DocumentShareScreenState createState() => _DocumentShareScreenState();
}

class _DocumentShareScreenState extends State<DocumentShareScreen> {
  List<Employee>? _employees;
  bool _isLoading = true;
  String? _error;
  List<int> _selectedEmployeeIds = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
    // Initialize with current shared users
    _selectedEmployeeIds = List.from(widget.document.sharedWith);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final employees = await widget.apiService.getEmployees();
      
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load employees: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Document'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildContent(),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _saveSharing,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.document.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Uploaded by: ${widget.document.uploadedByName}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select employees to share with:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: _employees == null || _employees!.isEmpty
              ? const Center(child: Text('No employees available'))
              : ListView.builder(
                  itemCount: _employees!.length,
                  itemBuilder: (context, index) {
                    final employee = _employees![index];
                    final isSelected = _selectedEmployeeIds.contains(employee.userId);
                    
                    return CheckboxListTile(
                      title: Text(employee.fullName),
                      subtitle: Text(employee.position),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedEmployeeIds.add(employee.userId);
                          } else {
                            _selectedEmployeeIds.remove(employee.userId);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _saveSharing() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await widget.apiService.shareDocument(widget.document.id, _selectedEmployeeIds);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document shared successfully')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to share document: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
