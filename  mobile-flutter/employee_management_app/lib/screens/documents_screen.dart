import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<Map<String, dynamic>> _documents = [
    {
      'id': 1,
      'title': 'Employee Handbook',
      'file_name': 'employee_handbook.pdf',
      'uploaded_by': 'Jane Smith',
      'uploaded_at': DateTime(2025, 1, 15),
      'file_size': '2.5 MB',
      'file_type': 'pdf',
    },
    {
      'id': 2,
      'title': 'Project Timeline',
      'file_name': 'project_timeline.xlsx',
      'uploaded_by': 'Jane Smith',
      'uploaded_at': DateTime(2025, 2, 20),
      'file_size': '1.2 MB',
      'file_type': 'xlsx',
    },
    {
      'id': 3,
      'title': 'Meeting Minutes',
      'file_name': 'meeting_minutes_2025_03_10.docx',
      'uploaded_by': 'John Doe',
      'uploaded_at': DateTime(2025, 3, 10),
      'file_size': '0.8 MB',
      'file_type': 'docx',
    },
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = _searchQuery.isEmpty
        ? _documents
        : _documents
            .where((doc) =>
                doc['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                doc['file_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search documents',
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
          Expanded(
            child: filteredDocuments.isEmpty
                ? const Center(
                    child: Text('No documents found'),
                  )
                : ListView.builder(
                    itemCount: filteredDocuments.length,
                    itemBuilder: (context, index) {
                      final document = filteredDocuments[index];
                      final uploadDate = DateFormat('MMM d, yyyy').format(document['uploaded_at']);
                      
                      IconData fileIcon;
                      Color iconColor;
                      
                      switch (document['file_type']) {
                        case 'pdf':
                          fileIcon = Icons.picture_as_pdf;
                          iconColor = Colors.red;
                          break;
                        case 'docx':
                          fileIcon = Icons.description;
                          iconColor = Colors.blue;
                          break;
                        case 'xlsx':
                          fileIcon = Icons.table_chart;
                          iconColor = Colors.green;
                          break;
                        default:
                          fileIcon = Icons.insert_drive_file;
                          iconColor = Colors.grey;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            fileIcon,
                            color: iconColor,
                            size: 36,
                          ),
                          title: Text(document['title']),
                          subtitle: Text('${document['file_name']} • ${document['file_size']}'),
                          trailing: const Icon(Icons.download),
                          onTap: () {
                            _showDocumentDetails(document);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUploadDocumentDialog();
        },
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  void _showDocumentDetails(Map<String, dynamic> document) {
    final uploadDate = DateFormat('MMM d, yyyy').format(document['uploaded_at']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(document['title']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text('File Name: ${document['file_name']}'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Uploaded By: ${document['uploaded_by']}'),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text('Upload Date: $uploadDate'),
              ),
              ListTile(
                leading: const Icon(Icons.data_usage),
                title: Text('File Size: ${document['file_size']}'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document downloaded')),
                );
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  void _showUploadDocumentDialog() {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    String _selectedFileName = 'No file selected';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Document'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Document Title',
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
                OutlinedButton.icon(
                  onPressed: () {
                    // In a real app, this would open a file picker
                    setState(() {
                      _selectedFileName = 'document.pdf';
                    });
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Select File'),
                ),
                const SizedBox(height: 8),
                Text(_selectedFileName),
              ],
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
                if (_formKey.currentState!.validate() && _selectedFileName != 'No file selected') {
                  Navigator.of(context).pop();
                  // Add new document
                  setState(() {
                    _documents.add({
                      'id': _documents.length + 1,
                      'title': _titleController.text,
                      'file_name': _selectedFileName,
                      'uploaded_by': 'John Doe',
                      'uploaded_at': DateTime.now(),
                      'file_size': '1.0 MB',
                      'file_type': _selectedFileName.split('.').last,
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document uploaded')),
                  );
                } else if (_selectedFileName == 'No file selected') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a file')),
                  );
                }
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }
}
