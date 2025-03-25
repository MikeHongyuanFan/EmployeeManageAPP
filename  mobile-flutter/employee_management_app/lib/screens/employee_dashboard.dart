import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'leave_request_screen.dart';
import 'wfh_request_screen.dart';
import 'tasks_screen.dart';
import 'meetings_screen.dart';
import 'documents_screen.dart';
import 'profile_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({Key? key}) : super(key: key);

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const LeaveRequestScreen(),
    const WfhRequestScreen(),
    const TasksScreen(),
    const MeetingsScreen(),
    const DocumentsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_busy),
            label: 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work),
            label: 'WFH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.fullName ?? "Employee"}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Department: ${user?.department ?? "Not assigned"}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Leave Balance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLeaveBalanceItem('Annual', '20', Colors.blue),
                  _buildLeaveBalanceItem('Sick', '10', Colors.red),
                  _buildLeaveBalanceItem('Personal', '5', Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pending Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_busy, color: Colors.orange),
              title: const Text('Annual Leave'),
              subtitle: const Text('May 10-12, 2025 • Pending'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to leave request details
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.home_work, color: Colors.blue),
              title: const Text('Work From Home'),
              subtitle: const Text('April 15, 2025 • Pending'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to WFH request details
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upcoming Tasks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment, color: Colors.red),
              title: const Text('Complete Project Proposal'),
              subtitle: const Text('Due: April 5, 2025 • High Priority'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to task details
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment, color: Colors.orange),
              title: const Text('Review Documentation'),
              subtitle: const Text('Due: April 10, 2025 • Medium Priority'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to task details
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Today\'s Meetings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.purple),
              title: const Text('Team Standup'),
              subtitle: const Text('9:00 AM - 9:30 AM • Meeting Room A'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to meeting details
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.purple),
              title: const Text('Project Review'),
              subtitle: const Text('2:00 PM - 3:00 PM • Conference Room'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to meeting details
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceItem(String type, String days, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              days,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          type,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
