import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class MeetingsScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  final bool isManager;
  
  const MeetingsScreen({
    Key? key, 
    required this.apiService,
    this.isManager = false,
  }) : super(key: key);

  @override
  _MeetingsScreenState createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  List<Meeting>? _meetings;
  List<Employee>? _employees;
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
      final meetings = await widget.apiService.getMeetings();
      
      if (widget.isManager) {
        final employees = await widget.apiService.getEmployees();
        setState(() {
          _meetings = meetings;
          _employees = employees;
          _isLoading = false;
        });
      } else {
        setState(() {
          _meetings = meetings;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load meetings: $e';
      });
      print('Error loading meetings: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _meetings!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No meetings found'),
                          if (widget.isManager) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _showCreateMeetingDialog,
                              child: const Text('Schedule Meeting'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        itemCount: _meetings!.length,
                        itemBuilder: (context, index) {
                          final meeting = _meetings![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(meeting.title),
                              subtitle: Text(
                                '${meeting.date} | ${meeting.startTime} - ${meeting.endTime}',
                              ),
                              trailing: widget.isManager
                                  ? IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showEditMeetingDialog(meeting),
                                    )
                                  : null,
                              onTap: () => _showMeetingDetails(meeting),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: widget.isManager
          ? FloatingActionButton(
              onPressed: _showCreateMeetingDialog,
              child: const Icon(Icons.add),
              tooltip: 'Schedule Meeting',
            )
          : null,
    );
  }
  
  Future<void> _showCreateMeetingDialog() async {
    if (_employees == null || _employees!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No employees available')),
      );
      return;
    }
    
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final locationController = TextEditingController();
    
    DateTime? selectedDate;
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;
    
    final selectedAttendees = <int>[];
    
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Schedule Meeting'),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.7,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
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
                          lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
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
                                  selectedStartTime = pickedTime;
                                  startTimeController.text = pickedTime.format(context);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () async {
                              if (selectedStartTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select start time first')),
                                );
                                return;
                              }
                              
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: (selectedStartTime!.hour + 1) % 24,
                                  minute: selectedStartTime!.minute,
                                ),
                              );
                              
                              if (pickedTime != null) {
                                setState(() {
                                  selectedEndTime = pickedTime;
                                  endTimeController.text = pickedTime.format(context);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Attendees',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _employees!.length,
                        itemBuilder: (context, index) {
                          final employee = _employees![index];
                          return CheckboxListTile(
                            title: Text(employee.fullName),
                            subtitle: Text(employee.position),
                            value: selectedAttendees.contains(employee.userId),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedAttendees.add(employee.userId);
                                } else {
                                  selectedAttendees.remove(employee.userId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty || 
                      dateController.text.isEmpty || 
                      startTimeController.text.isEmpty || 
                      endTimeController.text.isEmpty || 
                      selectedAttendees.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all required fields')),
                    );
                    return;
                  }
                  
                  final newMeeting = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'date': dateController.text,
                    'start_time': startTimeController.text,
                    'end_time': endTimeController.text,
                    'location': locationController.text,
                    'attendees': selectedAttendees,
                  };
                  
                  widget.apiService.createMeeting(newMeeting).then((_) {
                    Navigator.of(context).pop();
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meeting scheduled successfully')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to schedule meeting: $error')),
                    );
                  });
                },
                child: const Text('Schedule'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Future<void> _showEditMeetingDialog(Meeting meeting) async {
    if (_employees == null || _employees!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No employees available')),
      );
      return;
    }
    
    final titleController = TextEditingController(text: meeting.title);
    final descriptionController = TextEditingController(text: meeting.description);
    final dateController = TextEditingController(text: meeting.date);
    final startTimeController = TextEditingController(text: meeting.startTime);
    final endTimeController = TextEditingController(text: meeting.endTime);
    final locationController = TextEditingController(text: meeting.location);
    
    DateTime? selectedDate = DateFormat('yyyy-MM-dd').parse(meeting.date);
    TimeOfDay? selectedStartTime = TimeOfDay(
      hour: int.parse(meeting.startTime.split(':')[0]),
      minute: int.parse(meeting.startTime.split(':')[1]),
    );
    TimeOfDay? selectedEndTime = TimeOfDay(
      hour: int.parse(meeting.endTime.split(':')[0]),
      minute: int.parse(meeting.endTime.split(':')[1]),
    );
    final selectedAttendees = List<int>.from(meeting.attendees);
    
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Meeting'),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.7,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
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
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedStartTime ?? TimeOfDay.now(),
                              );
                              
                              if (pickedTime != null) {
                                setState(() {
                                  selectedStartTime = pickedTime;
                                  startTimeController.text = pickedTime.format(context);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () async {
                              if (selectedStartTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select start time first')),
                                );
                                return;
                              }
                              
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedEndTime ?? TimeOfDay(
                                  hour: (selectedStartTime!.hour + 1) % 24,
                                  minute: selectedStartTime!.minute,
                                ),
                              );
                              
                              if (pickedTime != null) {
                                setState(() {
                                  selectedEndTime = pickedTime;
                                  endTimeController.text = pickedTime.format(context);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Attendees',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _employees!.length,
                        itemBuilder: (context, index) {
                          final employee = _employees![index];
                          return CheckboxListTile(
                            title: Text(employee.fullName),
                            subtitle: Text(employee.position),
                            value: selectedAttendees.contains(employee.userId),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedAttendees.add(employee.userId);
                                } else {
                                  selectedAttendees.remove(employee.userId);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty || 
                      dateController.text.isEmpty || 
                      startTimeController.text.isEmpty || 
                      endTimeController.text.isEmpty || 
                      selectedAttendees.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all required fields')),
                    );
                    return;
                  }
                  
                  final updatedMeeting = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'date': dateController.text,
                    'start_time': startTimeController.text,
                    'end_time': endTimeController.text,
                    'location': locationController.text,
                    'attendees': selectedAttendees,
                  };
                  
                  widget.apiService.updateMeeting(meeting.id, updatedMeeting).then((_) {
                    Navigator.of(context).pop();
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meeting updated successfully')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update meeting: $error')),
                    );
                  });
                },
                child: const Text('Update'),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Meeting'),
                      content: const Text('Are you sure you want to delete this meeting?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Since deleteMeeting is not in the interface, we'll use updateMeeting with a special flag
                            final deleteRequest = {
                              'delete': true,
                            };
                            widget.apiService.updateMeeting(meeting.id, deleteRequest).then((_) {
                              Navigator.of(context).pop();
                              _loadData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Meeting deleted successfully')),
                              );
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete meeting: $error')),
                              );
                            });
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showMeetingDetails(Meeting meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meeting.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meeting.description.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(meeting.description),
              const SizedBox(height: 16),
            ],
            const Text(
              'Date & Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${meeting.date} | ${meeting.startTime} - ${meeting.endTime}'),
            const SizedBox(height: 16),
            if (meeting.location.isNotEmpty) ...[
              const Text(
                'Location:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(meeting.location),
              const SizedBox(height: 16),
            ],
            const Text(
              'Attendees:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_employees != null)
              ...meeting.attendees.map((id) {
                final employee = _employees!.firstWhere(
                  (e) => e.userId == id,
                  orElse: () => Employee(
                    id: 0,
                    userId: id,
                    firstName: 'Unknown',
                    lastName: 'Employee',
                    email: '',
                    employeeId: '',
                    position: '',
                    departmentName: '',
                    joinDate: '',
                    leaveBalance: {},
                    isActive: true,
                  ),
                );
                return Text('• ${employee.fullName}');
              }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
