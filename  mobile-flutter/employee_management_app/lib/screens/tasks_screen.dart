import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/status_chip.dart';
import '../utils/constants.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': 1,
      'title': 'Complete Project Proposal',
      'description': 'Finalize the project proposal document for client review',
      'assigned_by': 'Jane Smith',
      'priority': 'High',
      'status': 'pending',
      'due_date': DateTime(2025, 4, 5),
    },
    {
      'id': 2,
      'title': 'Review Documentation',
      'description': 'Review the technical documentation for the new feature',
      'assigned_by': 'Jane Smith',
      'priority': 'Medium',
      'status': 'in progress',
      'due_date': DateTime(2025, 4, 10),
    },
    {
      'id': 3,
      'title': 'Fix Login Bug',
      'description': 'Fix the login issue reported by the QA team',
      'assigned_by': 'Jane Smith',
      'priority': 'High',
      'status': 'completed',
      'due_date': DateTime(2025, 3, 25),
    },
  ];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _selectedFilter == 'All'
        ? _tasks
        : _tasks.where((task) => task['status'].toString().toLowerCase() == _selectedFilter.toLowerCase()).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('In Progress'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredTasks.isEmpty
          ? const Center(
              child: Text('No tasks found'),
            )
          : ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final dueDate = DateFormat('MMM d, yyyy').format(task['due_date']);
                
                Color priorityColor;
                switch (task['priority'].toString().toLowerCase()) {
                  case 'high':
                    priorityColor = Colors.red;
                    break;
                  case 'medium':
                    priorityColor = Colors.orange;
                    break;
                  default:
                    priorityColor = Colors.green;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Text('Due: $dueDate'),
                    leading: CircleAvatar(
                      backgroundColor: priorityColor.withOpacity(0.2),
                      child: Text(
                        task['priority'].toString().substring(0, 1),
                        style: TextStyle(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailing: StatusChip(status: task['status']),
                    onTap: () {
                      _showTaskDetails(task);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == label,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    final dueDate = DateFormat('MMM d, yyyy').format(task['due_date']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(task['description']),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Assigned by: ${task['assigned_by']}'),
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: Text('Priority: ${task['priority']}'),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text('Due Date: $dueDate'),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Row(
                  children: [
                    const Text('Status: '),
                    StatusChip(status: task['status']),
                  ],
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
            if (task['status'] != 'completed')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Update task status
                  setState(() {
                    final index = _tasks.indexWhere((t) => t['id'] == task['id']);
                    if (index != -1) {
                      _tasks[index]['status'] = 'completed';
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task marked as completed')),
                  );
                },
                child: const Text('Mark as Completed'),
              ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog() {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    String _selectedPriority = Constants.taskPriorities[1]; // Medium
    DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Task'),
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
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: Constants.taskPriorities.map((priority) {
                      return DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _selectedPriority = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_dueDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) {
                        setState(() {
                          _dueDate = date;
                        });
                      }
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
                  // Add new task
                  setState(() {
                    _tasks.add({
                      'id': _tasks.length + 1,
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'assigned_by': 'Self',
                      'priority': _selectedPriority,
                      'status': 'pending',
                      'due_date': _dueDate,
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task added')),
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
