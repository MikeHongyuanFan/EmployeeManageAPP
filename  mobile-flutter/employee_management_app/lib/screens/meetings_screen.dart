import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  _MeetingsScreenState createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  final Map<DateTime, List<Map<String, dynamic>>> _meetings = {
    DateTime(2025, 3, 24): [
      {
        'id': 1,
        'title': 'Team Standup',
        'start_time': '09:00',
        'end_time': '09:30',
        'location': 'Meeting Room A',
        'participants': ['John Doe', 'Jane Smith', 'Mike Johnson'],
      },
      {
        'id': 2,
        'title': 'Project Review',
        'start_time': '14:00',
        'end_time': '15:00',
        'location': 'Conference Room',
        'participants': ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Williams'],
      },
    ],
    DateTime(2025, 3, 25): [
      {
        'id': 3,
        'title': 'Client Meeting',
        'start_time': '10:00',
        'end_time': '11:30',
        'location': 'Conference Room',
        'participants': ['John Doe', 'Jane Smith', 'Client Representative'],
      },
    ],
    DateTime(2025, 3, 27): [
      {
        'id': 4,
        'title': 'Sprint Planning',
        'start_time': '13:00',
        'end_time': '15:00',
        'location': 'Meeting Room B',
        'participants': ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Williams'],
      },
    ],
  };

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _meetings[normalizedDay] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildMeetingsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMeetingDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMeetingsList() {
    final meetings = _getEventsForDay(_selectedDay!);
    
    if (meetings.isEmpty) {
      return const Center(
        child: Text('No meetings scheduled for this day'),
      );
    }
    
    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(meeting['title']),
            subtitle: Text('${meeting['start_time']} - ${meeting['end_time']} • ${meeting['location']}'),
            leading: const CircleAvatar(
              child: Icon(Icons.calendar_today),
            ),
            onTap: () {
              _showMeetingDetails(meeting);
            },
          ),
        );
      },
    );
  }

  void _showMeetingDetails(Map<String, dynamic> meeting) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(meeting['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('${meeting['start_time']} - ${meeting['end_time']}'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(meeting['location']),
              ),
              const ListTile(
                leading: Icon(Icons.people),
                title: Text('Participants:'),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    meeting['participants'].length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• ${meeting['participants'][index]}'),
                    ),
                  ),
                ),
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
          ],
        );
      },
    );
  }

  void _showAddMeetingDialog() {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _locationController = TextEditingController();
    DateTime _meetingDate = _selectedDay ?? DateTime.now();
    TimeOfDay _startTime = TimeOfDay.now();
    TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Meeting'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_meetingDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _meetingDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) {
                        setState(() {
                          _meetingDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) {
                        setState(() {
                          _startTime = time;
                          // Ensure end time is after start time
                          if (_endTime.hour < _startTime.hour ||
                              (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
                            _endTime = TimeOfDay(
                              hour: _startTime.hour + 1,
                              minute: _startTime.minute,
                            );
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) {
                        setState(() {
                          _endTime = time;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  // Add new meeting
                  final normalizedDate = DateTime(_meetingDate.year, _meetingDate.month, _meetingDate.day);
                  final newMeeting = {
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'title': _titleController.text,
                    'start_time': _startTime.format(context),
                    'end_time': _endTime.format(context),
                    'location': _locationController.text,
                    'participants': ['John Doe', 'Jane Smith'],
                  };
                  
                  setState(() {
                    if (_meetings.containsKey(normalizedDate)) {
                      _meetings[normalizedDate]!.add(newMeeting);
                    } else {
                      _meetings[normalizedDate] = [newMeeting];
                    }
                    _selectedDay = normalizedDate;
                    _focusedDay = normalizedDate;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting added')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
