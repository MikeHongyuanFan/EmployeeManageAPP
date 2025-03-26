import 'package:flutter/material.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';
import 'leave_requests_screen.dart';
import 'wfh_requests_screen.dart';
import 'tasks_screen.dart';
import 'meetings_screen.dart';
import 'documents_screen.dart';
import 'working_hours_screen.dart';
import 'profile_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  final ApiServiceInterface apiService;
  
  const EmployeeDashboard({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;
  
  // Mock data for dashboard
  String _userName = 'Employee';
  Map<String, int> _leaveBalance = {'annual': 0, 'sick': 0, 'personal': 0};
  int _pendingTasks = 0;
  int _pendingWfhRequests = 0;
  bool _isClockedIn = false;
  
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
      
      // Get tasks
      final tasks = await widget.apiService.getTasks();
      
      // Get leave requests
      final leaveRequests = await widget.apiService.getLeaveRequests();
      
      // Get working times
      final workingTimes = await widget.apiService.getWorkingTimes();
      
      setState(() {
        _userName = '${employee.firstName} ${employee.lastName}';
        _leaveBalance = employee.leaveBalance;
        _pendingTasks = tasks.where((task) => task.status != 'Completed').length;
        _pendingWfhRequests = leaveRequests.where((req) => req.status == 'Pending').length;
        
        // Check if clocked in today
        final now = DateTime.now();
        final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final todayWorkingTime = workingTimes.where((wt) => 
          wt.date == today && wt.clockOut == null).toList();
        _isClockedIn = todayWorkingTime.isNotEmpty;
        
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
  
  Future<void> _clockInOut() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_isClockedIn) {
        await widget.apiService.clockOut();
      } else {
        await widget.apiService.clockIn();
      }
      
      setState(() {
        _isClockedIn = !_isClockedIn;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isClockedIn ? 'Clocked in successfully' : 'Clocked out successfully'),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      LeaveRequestsScreen(apiService: widget.apiService),
      WfhRequestsScreen(apiService: widget.apiService),
      TasksScreen(apiService: widget.apiService),
      MeetingsScreen(apiService: widget.apiService),
      DocumentsScreen(apiService: widget.apiService),
      WorkingHoursScreen(apiService: widget.apiService),
      ProfileScreen(apiService: widget.apiService),
    ];
    
    // Make sure _selectedIndex is within valid range
    if (_selectedIndex >= _screens.length) {
      _selectedIndex = 0;
    }
    
    // Define bottom navigation items
    final bottomNavItems = const [
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
        icon: Icon(Icons.event),
        label: 'Meetings',
      ),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Dashboard'),
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
        currentIndex: _selectedIndex < bottomNavItems.length ? _selectedIndex : 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: bottomNavItems,
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
                      _userName.isNotEmpty ? _userName[0] : 'E',
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
                    'Employee',
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
              leading: Icon(Icons.event_busy),
              title: Text('Leave Requests'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.home_work),
              title: Text('WFH Requests'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Tasks'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Meetings'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Documents'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Working Hours'),
              selected: _selectedIndex == 6,
              onTap: () {
                setState(() {
                  _selectedIndex = 6;
                });
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              selected: _selectedIndex == 7,
              onTap: () {
                setState(() {
                  _selectedIndex = 7;
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
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _clockInOut,
                      icon: Icon(_isClockedIn ? Icons.logout : Icons.login),
                      label: Text(_isClockedIn ? 'Clock Out' : 'Clock In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isClockedIn ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Leave Balance',
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
                    _buildLeaveBalanceItem('Annual', _leaveBalance['annual'] ?? 0, Colors.blue),
                    _buildLeaveBalanceItem('Sick', _leaveBalance['sick'] ?? 0, Colors.red),
                    _buildLeaveBalanceItem('Personal', _leaveBalance['personal'] ?? 0, Colors.green),
                  ],
                ),
              ),
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
                    'Tasks',
                    '$_pendingTasks pending',
                    Icons.assignment,
                    Colors.orange,
                    () {
                      setState(() {
                        _selectedIndex = 3;
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
                        _selectedIndex = 2;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Apply Leave',
                    'Request time off',
                    Icons.event_busy,
                    Colors.teal,
                    () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    'Meetings',
                    'View schedule',
                    Icons.event,
                    Colors.indigo,
                    () {
                      setState(() {
                        _selectedIndex = 4;
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
  
  Widget _buildLeaveBalanceItem(String type, int days, Color color) {
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
              days.toString(),
              style: TextStyle(
                fontSize: 24,
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
