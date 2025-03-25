import 'package:flutter/material.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final List<Map<String, dynamic>> _employees = [
    {
      'id': 'EMP-12345',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'department': 'Engineering',
      'position': 'Software Developer',
      'avatar': 'JD',
      'status': 'Present',
    },
    {
      'id': 'EMP-23456',
      'name': 'Mary Johnson',
      'email': 'mary.johnson@example.com',
      'department': 'Engineering',
      'position': 'QA Engineer',
      'avatar': 'MJ',
      'status': 'WFH',
    },
    {
      'id': 'EMP-34567',
      'name': 'Robert Smith',
      'email': 'robert.smith@example.com',
      'department': 'Design',
      'position': 'UI/UX Designer',
      'avatar': 'RS',
      'status': 'Present',
    },
    {
      'id': 'EMP-45678',
      'name': 'Sarah Williams',
      'email': 'sarah.williams@example.com',
      'department': 'Marketing',
      'position': 'Marketing Specialist',
      'avatar': 'SW',
      'status': 'On Leave',
    },
    {
      'id': 'EMP-56789',
      'name': 'Michael Brown',
      'email': 'michael.brown@example.com',
      'department': 'Finance',
      'position': 'Financial Analyst',
      'avatar': 'MB',
      'status': 'Present',
    },
    {
      'id': 'EMP-67890',
      'name': 'Jennifer Davis',
      'email': 'jennifer.davis@example.com',
      'department': 'HR',
      'position': 'HR Manager',
      'avatar': 'JD',
      'status': 'Present',
    },
    {
      'id': 'EMP-78901',
      'name': 'David Wilson',
      'email': 'david.wilson@example.com',
      'department': 'Engineering',
      'position': 'DevOps Engineer',
      'avatar': 'DW',
      'status': 'WFH',
    },
  ];

  String _searchQuery = '';
  String _selectedDepartment = 'All';

  final List<String> _departments = [
    'All',
    'Engineering',
    'Design',
    'Marketing',
    'Finance',
    'HR',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter employees based on search query and department
    final filteredEmployees = _employees.where((employee) {
      final matchesSearch = employee['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          employee['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesDepartment = _selectedDepartment == 'All' || 
          employee['department'] == _selectedDepartment;
      
      return matchesSearch && matchesDepartment;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search employees',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _departments.map((department) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(department),
                    selected: _selectedDepartment == department,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDepartment = department;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(
                    child: Text('No employees found'),
                  )
                : ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      
                      Color statusColor;
                      switch (employee['status']) {
                        case 'Present':
                          statusColor = Colors.green;
                          break;
                        case 'WFH':
                          statusColor = Colors.blue;
                          break;
                        case 'On Leave':
                          statusColor = Colors.orange;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Text(employee['avatar'])),
                          title: Text(employee['name']),
                          subtitle: Text('${employee['position']} • ${employee['department']}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              employee['status'],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () {
                            _showEmployeeDetails(employee);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showEmployeeDetails(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(employee['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    employee['avatar'],
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.badge),
                title: Text('Employee ID: ${employee['id']}'),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text('Email: ${employee['email']}'),
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: Text('Department: ${employee['department']}'),
              ),
              ListTile(
                leading: const Icon(Icons.work),
                title: Text('Position: ${employee['position']}'),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text('Status: ${employee['status']}'),
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to employee tasks
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View tasks functionality coming soon')),
                );
              },
              child: const Text('View Tasks'),
            ),
          ],
        );
      },
    );
  }
}
