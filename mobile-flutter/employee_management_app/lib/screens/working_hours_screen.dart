import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class WorkingHoursScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  final bool isManager;
  
  const WorkingHoursScreen({
    Key? key, 
    required this.apiService,
    this.isManager = false,
  }) : super(key: key);

  @override
  _WorkingHoursScreenState createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  List<WorkingTime>? _workingHours;
  bool _isLoading = true;
  String? _error;
  bool _isClockedIn = false;
  WorkingTime? _currentSession;

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
      final workingHours = await widget.apiService.getWorkingHours();
      
      // Check if there's an active session (clocked in but not out)
      final activeSession = workingHours.where((wh) => wh.clockOut == null).toList();
      
      setState(() {
        _workingHours = workingHours;
        _isClockedIn = activeSession.isNotEmpty;
        _currentSession = activeSession.isNotEmpty ? activeSession.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load working hours: ${e.toString()}';
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
        title: const Text('Working Hours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogHoursDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Log Hours Manually',
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
                      _buildClockInOutCard(),
                      const SizedBox(height: 16),
                      _buildSummaryCard(),
                      const SizedBox(height: 16),
                      _buildWorkingHoursHistory(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildClockInOutCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clock In/Out',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isClockedIn && _currentSession != null) ...[
              Text('Clocked in at: ${_currentSession!.clockIn}'),
              const SizedBox(height: 8),
              Text('Date: ${_currentSession!.date}'),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isClockedIn ? null : () => _clockIn(),
                  icon: const Icon(Icons.login),
                  label: const Text('Clock In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isClockedIn ? () => _clockOut() : null,
                  icon: const Icon(Icons.logout),
                  label: const Text('Clock Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_workingHours == null || _workingHours!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Calculate weekly and monthly hours
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    double weeklyHours = 0;
    double monthlyHours = 0;
    
    for (var entry in _workingHours!) {
      final entryDate = DateTime.parse(entry.date);
      
      if (entryDate.isAfter(startOfWeek) || 
          (entryDate.day == startOfWeek.day && 
           entryDate.month == startOfWeek.month && 
           entryDate.year == startOfWeek.year)) {
        weeklyHours += entry.hoursWorked;
      }
      
      if (entryDate.isAfter(startOfMonth) || 
          (entryDate.day == startOfMonth.day && 
           entryDate.month == startOfMonth.month && 
           entryDate.year == startOfMonth.year)) {
        monthlyHours += entry.hoursWorked;
      }
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('This Week', '${weeklyHours.toStringAsFixed(1)} hrs'),
                _buildSummaryItem('This Month', '${monthlyHours.toStringAsFixed(1)} hrs'),
                _buildSummaryItem('Total Entries', '${_workingHours!.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHoursHistory() {
    if (_workingHours == null || _workingHours!.isEmpty) {
      return const Center(child: Text('No working hours recorded yet'));
    }
    
    // Group by date
    final Map<String, List<WorkingTime>> groupedEntries = {};
    
    for (var entry in _workingHours!) {
      if (!groupedEntries.containsKey(entry.date)) {
        groupedEntries[entry.date] = [];
      }
      groupedEntries[entry.date]!.add(entry);
    }
    
    // Sort dates in descending order
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...sortedDates.map((date) {
          final entries = groupedEntries[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...entries.map((workingTime) => _buildWorkingTimeCard(workingTime)),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWorkingTimeCard(WorkingTime workingTime) {
    final bool isActive = workingTime.clockOut == null;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isActive ? Colors.blue.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clock In: ${workingTime.clockIn}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
            if (workingTime.clockOut != null)
              Text('Clock Out: ${workingTime.clockOut}'),
            const SizedBox(height: 4),
            Text(
              workingTime.clockOut != null
                  ? '${workingTime.hoursWorked} hours'
                  : 'In progress',
              style: TextStyle(
                color: isActive ? Colors.blue : Colors.grey[700],
              ),
            ),
            if (workingTime.description != null && workingTime.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Description: ${workingTime.description}'),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _clockIn() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final notesController = TextEditingController();
      String? notes;
      
      // Optionally ask for notes
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Notes (Optional)'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(
              hintText: 'Enter any notes for this session',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                notes = notesController.text;
                Navigator.of(context).pop();
              },
              child: const Text('Clock In'),
            ),
          ],
        ),
      );
      
      await widget.apiService.clockIn(notes: notes);
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clocked in successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to clock in: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _clockOut() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final notesController = TextEditingController();
      String? notes;
      
      // Optionally ask for notes
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Notes (Optional)'),
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(
              hintText: 'Enter any notes for this session',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                notes = notesController.text;
                Navigator.of(context).pop();
              },
              child: const Text('Clock Out'),
            ),
          ],
        ),
      );
      
      await widget.apiService.clockOut(notes: notes);
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clocked out successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to clock out: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _showLogHoursDialog() async {
    final dateController = TextEditingController();
    final clockInController = TextEditingController();
    final clockOutController = TextEditingController();
    final notesController = TextEditingController();
    
    DateTime? selectedDate;
    TimeOfDay? selectedClockIn;
    TimeOfDay? selectedClockOut;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Working Hours'),
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
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
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
                  controller: clockInController,
                  decoration: const InputDecoration(
                    labelText: 'Clock In Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    
                    if (pickedTime != null) {
                      setState(() {
                        selectedClockIn = pickedTime;
                        clockInController.text = pickedTime.format(context);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: clockOutController,
                  decoration: const InputDecoration(
                    labelText: 'Clock Out Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  readOnly: true,
                  onTap: () async {
                    if (selectedClockIn == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select clock in time first')),
                      );
                      return;
                    }
                    
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: (selectedClockIn!.hour + 1) % 24,
                        minute: selectedClockIn!.minute,
                      ),
                    );
                    
                    if (pickedTime != null) {
                      // Validate that clock out is after clock in
                      final now = DateTime.now();
                      final clockInTime = DateTime(
                        now.year, now.month, now.day,
                        selectedClockIn!.hour, selectedClockIn!.minute,
                      );
                      final clockOutTime = DateTime(
                        now.year, now.month, now.day,
                        pickedTime.hour, pickedTime.minute,
                      );
                      
                      if (clockOutTime.isBefore(clockInTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Clock out time must be after clock in time')),
                        );
                        return;
                      }
                      
                      setState(() {
                        selectedClockOut = pickedTime;
                        clockOutController.text = pickedTime.format(context);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
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
                if (dateController.text.isEmpty || 
                    clockInController.text.isEmpty || 
                    clockOutController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                await _logWorkingHours(
                  dateController.text,
                  clockInController.text,
                  clockOutController.text,
                  notesController.text,
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logWorkingHours(String date, String clockIn, String clockOut, String notes) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final workingHoursData = {
        'date': date,
        'clock_in': '$date $clockIn:00',
        'clock_out': '$date $clockOut:00',
        'notes': notes,
      };
      
      await widget.apiService.logWorkingHours(workingHoursData);
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Working hours logged successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to log working hours: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
