import 'package:flutter/material.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';
import 'employees_screen.dart';
import 'leave_approval_screen.dart';
import 'wfh_approval_screen.dart';
import 'tasks_screen.dart';
import 'meetings_screen.dart';
import 'documents_screen.dart';
import 'working_hours_screen.dart';
import 'profile_screen.dart';

class ManagerDashboard extends StatefulWidget {
  final ApiServiceInterface apiService;
  
  const ManagerDashboard({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  _ManagerDashboardState createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;
  
  // Mock data for dashboard
  String _userName = 'Manager';
  int _pendingLeaveRequests = 0;
  int _pendingWfhRequests = 0;
  int _employeeCount = 0;
  int _upcomingMeetings = 0;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Get current employee data
      final employee = await widget.apiService.getCurrentEmployee();
      
      // Get employees
      final employees = await widget.apiService.getEmployees();
      
      // Get leave requests
      final leaveRequests = await widget.apiService.getLeaveRequests();
      
      // Get WFH requests
      final wfhRequests = await widget.apiService.getWfhRequests();
      
      // Get meetings
      final meetings = await widget.apiService.getMeetings();
      
      setState(() {
        _userName = '${employee.firstName} ${employee.lastName}';
        _employeeCount = employees.length;
        _pendingLeaveRequests = leaveRequests.where((req) => req.status.toLowerCase() == 'pending').length;
        _pendingWfhRequests = wfhRequests.where((req) => req.status.toLowerCase() == 'pending').length;
        
        // Get today's date and filter upcoming meetings
        final now = DateTime.now();
        final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        _upcomingMeetings = meetings.where((m) => m.date.compareTo(today) >= 0).length;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load dashboard data: $e';
      });
      print('Dashboard error: $e');
    }
  }
  
  Future<void> _logout() async {
    await widget.apiService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _buildDashboardScreen(),
      EmployeesScreen(apiService: widget.apiService),
      LeaveApprovalScreen(apiService: widget.apiService),
      WfhApprovalScreen(apiService: widget.apiService),
      TasksScreen(apiService: widget.apiService, isManager: true),
      MeetingsScreen(apiService: widget.apiService, isManager: true),
      DocumentsScreen(apiService: widget.apiService, isManager: true),
      WorkingHoursScreen(apiService: widget.apiService, isManager: true),
      ProfileScreen(apiService: widget.apiService),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex, // Ensure index is within range
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Employees',
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
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0] : 'M',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Manager',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Employees'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event_busy),
              title: Text('Leave Approval'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.home_work),
              title: Text('WFH Requests'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Tasks'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Meetings'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Documents'),
              selected: _selectedIndex == 6,
              onTap: () {
                setState(() {
                  _selectedIndex = 6;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Working Hours'),
              selected: _selectedIndex == 7,
              onTap: () {
                setState(() {
                  _selectedIndex = 7;
                });
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              selected: _selectedIndex == 8,
              onTap: () {
                setState(() {
                  _selectedIndex = 8;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDashboardScreen() {
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
              'Error loading dashboard',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(_error!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $_userName',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Today is ${DateTime.now().toString().split(' ')[0]}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Team Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOverviewItem('Employees', _employeeCount, Icons.people, Colors.blue),
                    _buildOverviewItem('Meetings', _upcomingMeetings, Icons.event, Colors.orange),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Pending Approvals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Leave Requests',
                    '$_pendingLeaveRequests pending',
                    Icons.event_busy,
                    Colors.red,
                    () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    'WFH Requests',
                    '$_pendingWfhRequests pending',
                    Icons.home_work,
                    Colors.purple,
                    () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Assign Tasks',
                    'Manage team tasks',
                    Icons.assignment,
                    Colors.teal,
                    () {
                      setState(() {
                        _selectedIndex = 4;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    'Schedule Meeting',
                    'Create new meeting',
                    Icons.event,
                    Colors.indigo,
                    () {
                      setState(() {
                        _selectedIndex = 5;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewItem(String title, int count, IconData icon, Color color) {
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
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
