import 'package:flutter/material.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class ProfileScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  
  const ProfileScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  Employee? _employee;
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
      final user = await widget.apiService.getUserProfile();
      final employee = await widget.apiService.getEmployeeProfile();
      
      setState(() {
        _user = user;
        _employee = employee;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load profile: ${e.toString()}';
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
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        backgroundColor: widget.apiService.isManager ?? false ? Colors.purple : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildEmploymentDetails(),
                      const SizedBox(height: 24),
                      _buildContactDetails(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: widget.apiService.isManager ?? false ? Colors.purple.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
            child: Text(
              _user?.initials ?? 'JD',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: widget.apiService.isManager ?? false ? Colors.purple : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user?.fullName ?? 'John Doe',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _employee?.position ?? (widget.apiService.isManager ?? false ? 'Manager' : 'Employee'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.apiService.isManager ?? false ? Colors.purple.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.apiService.isManager ?? false ? 'Manager' : 'Employee',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.apiService.isManager ?? false ? Colors.purple : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('Employee ID', _employee?.employeeId ?? 'N/A'),
            _buildInfoItem('Department', _employee?.departmentName ?? 'N/A'),
            _buildInfoItem('Position', _employee?.position ?? 'N/A'),
            _buildInfoItem('Date Joined', _employee?.dateJoined ?? 'N/A'),
            _buildInfoItem('Manager', _employee?.managerName ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('Email', _user?.email ?? 'N/A'),
            _buildInfoItem('Phone', _employee?.phone ?? 'N/A'),
            _buildInfoItem('Address', _employee?.address ?? 'N/A'),
            _buildInfoItem('Emergency Contact', _employee?.emergencyContact ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
