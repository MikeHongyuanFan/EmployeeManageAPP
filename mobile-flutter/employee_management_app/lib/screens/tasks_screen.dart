import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class TasksScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  final bool isManager;
  
  const TasksScreen({
    Key? key, 
    required this.apiService,
    this.isManager = false,
  }) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task>? _tasks;
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
      final tasks = await widget.apiService.getTasks();
      
      List<Employee>? employees;
      if (widget.isManager) {
        employees = await widget.apiService.getEmployees();
      }
      
      setState(() {
        _tasks = tasks;
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load tasks: ${e.toString()}';
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
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: widget.isManager
          ? FloatingActionButton(
              onPressed: () => _showCreateTaskDialog(),
              child: const Icon(Icons.add),
              tooltip: 'Create Task',
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _tasks == null || _tasks!.isEmpty
                  ? const Center(child: Text('No tasks found'))
                  : _buildTasksList(),
    );
  }

  Widget _buildTasksList() {
    // Group tasks by status
    final notStartedTasks = _tasks!.where((task) => task.status == 'not_started').toList();
    final inProgressTasks = _tasks!.where((task) => task.status == 'in_progress').toList();
    final completedTasks = _tasks!.where((task) => task.status == 'completed').toList();
    final overdueTasks = _tasks!.where((task) => task.status == 'overdue').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overdueTasks.isNotEmpty) ...[
            const Text(
              'Overdue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ...overdueTasks.map((task) => _buildTaskCard(task)),
            const SizedBox(height: 24),
          ],
          if (inProgressTasks.isNotEmpty) ...[
            const Text(
              'In Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            ...inProgressTasks.map((task) => _buildTaskCard(task)),
            const SizedBox(height: 24),
          ],
          if (notStartedTasks.isNotEmpty) ...[
            const Text(
              'Not Started',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...notStartedTasks.map((task) => _buildTaskCard(task)),
            const SizedBox(height: 24),
          ],
          if (completedTasks.isNotEmpty) ...[
            const Text(
              'Completed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ...completedTasks.map((task) => _buildTaskCard(task)),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final bool isAssignedToMe = task.assignedToId == widget.apiService.userId;
    final bool canUpdateStatus = isAssignedToMe || widget.isManager;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Task.getPriorityColor(task.priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Task.getPriorityColor(task.priority),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Assigned by: ${task.assignedByName}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Assigned to: ${task.assignedToName}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Due: ${task.dueDate}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Task.getStatusColor(task.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Task.getStatusIcon(task.status),
                        size: 16,
                        color: Task.getStatusColor(task.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatStatus(task.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Task.getStatusColor(task.status),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canUpdateStatus && task.status != 'completed')
                  TextButton(
                    onPressed: () => _showUpdateStatusDialog(task),
                    child: const Text('Update Status'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'not_started':
        return 'NOT STARTED';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      case 'overdue':
        return 'OVERDUE';
      default:
        return status.toUpperCase();
    }
  }

  Future<void> _showUpdateStatusDialog(Task task) async {
    String selectedStatus = task.status;
    
    final statusOptions = [
      'not_started',
      'in_progress',
      'completed',
    ];
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Task Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...statusOptions.map(
                (status) => RadioListTile<String>(
                  title: Text(_formatStatus(status)),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateTaskStatus(task.id, selectedStatus);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTaskStatus(int taskId, String status) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await widget.apiService.updateTask(taskId, {'status': status});
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task status updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to update task status: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _showCreateTaskDialog() async {
    if (_employees == null || _employees!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No employees available to assign tasks')),
      );
      return;
    }
    
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController();
    
    DateTime? selectedDate;
    String selectedPriority = 'medium';
    int? selectedEmployeeId;
    
    final priorityOptions = ['low', 'medium', 'high'];
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Task'),
          content: SingleChildScrollView(
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
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: priorityOptions.map((priority) {
                    return DropdownMenuItem<String>(
                      value: priority,
                      child: Text(priority.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPriority = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Assign To',
                    border: OutlineInputBorder(),
                  ),
                  items: _employees!.map((employee) {
                    return DropdownMenuItem<int>(
                      value: employee.userId,
                      child: Text(employee.fullName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedEmployeeId = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        dueDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
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
              onPressed: () {
                if (titleController.text.isEmpty || 
                    dueDateController.text.isEmpty || 
                    selectedEmployeeId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                Navigator.of(context).pop();
                _createTask(
                  titleController.text,
                  descriptionController.text,
                  selectedPriority,
                  selectedEmployeeId!,
                  dueDateController.text,
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTask(String title, String description, String priority, int assignedToId, String dueDate) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final taskData = {
        'title': title,
        'description': description,
        'priority': priority,
        'assigned_to_id': assignedToId,
        'due_date': dueDate,
        'status': 'not_started',
      };
      
      await widget.apiService.createTask(taskData);
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to create task: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
