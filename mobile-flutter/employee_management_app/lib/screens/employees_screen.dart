import 'package:flutter/material.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class EmployeesScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  
  const EmployeesScreen({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  bool _isLoading = true;
  String? _error;
  List<Employee> _employees = [];
  
  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }
  
  Future<void> _loadEmployees() async {
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
        _isLoading = false;
        _error = 'Failed to load employees: $e';
      });
      print('Error loading employees: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error loading employees',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(_error!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_employees.isEmpty) {
      return Center(
        child: Text('No employees found'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  employee.firstName[0] + employee.lastName[0],
                ),
              ),
              title: Text('${employee.firstName} ${employee.lastName}'),
              subtitle: Text(employee.position),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                _showEmployeeDetails(employee);
              },
            ),
          );
        },
      ),
    );
  }
  
  void _showEmployeeDetails(Employee employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Text(
                    employee.firstName[0] + employee.lastName[0],
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  '${employee.firstName} ${employee.lastName}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  employee.position,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 24),
              _buildInfoRow('Department', employee.departmentName),
              _buildInfoRow('Employee ID', employee.employeeId),
              _buildInfoRow('Email', employee.email),
              if (employee.phone != null) _buildInfoRow('Phone', employee.phone!),
              _buildInfoRow('Join Date', employee.joinDate),
              SizedBox(height: 16),
              Text(
                'Leave Balance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLeaveBalanceItem('Annual', employee.leaveBalance['annual'] ?? 0, Colors.blue),
                  _buildLeaveBalanceItem('Sick', employee.leaveBalance['sick'] ?? 0, Colors.red),
                  _buildLeaveBalanceItem('Personal', employee.leaveBalance['personal'] ?? 0, Colors.green),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to assign task screen
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.assignment),
                    label: Text('Assign Task'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to schedule meeting screen
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.event),
                    label: Text('Schedule Meeting'),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeaveBalanceItem(String type, int days, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              days.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          type,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
