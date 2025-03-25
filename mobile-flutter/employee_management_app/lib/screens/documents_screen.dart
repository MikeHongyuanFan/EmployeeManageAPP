import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service_interface.dart';
import '../models/models.dart';

class DocumentsScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  final bool isManager;
  
  const DocumentsScreen({
    Key? key, 
    required this.apiService,
    this.isManager = false,
  }) : super(key: key);

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Document>? _documents;
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
      final documents = await widget.apiService.getDocuments();
      
      List<Employee>? employees;
      if (widget.isManager) {
        employees = await widget.apiService.getEmployees();
      }
      
      setState(() {
        _documents = documents;
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load documents: ${e.toString()}';
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
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadDocumentDialog(),
        child: const Icon(Icons.upload_file),
        tooltip: 'Upload Document',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _documents == null || _documents!.isEmpty
                  ? const Center(child: Text('No documents found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _documents!.length,
                      itemBuilder: (context, index) {
                        final document = _documents![index];
                        return _buildDocumentCard(document);
                      },
                    ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    final bool canManage = document.uploadedBy == widget.apiService.userId || widget.isManager;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(
              _getFileIcon(document),
              size: 40,
              color: Colors.blue,
            ),
            title: Text(
              document.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(document.fileName),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'download':
                    _downloadDocument(document);
                    break;
                  case 'share':
                    _showShareDocumentDialog(document);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(document);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Download'),
                    ],
                  ),
                ),
                if (canManage)
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                if (canManage)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (document.description.isNotEmpty) ...[
                  Text('Description: ${document.description}'),
                  const SizedBox(height: 8),
                ],
                Text('Uploaded by: ${document.uploadedByName}'),
                Text('Date: ${document.uploadDate}'),
                if (document.sharedWithNames.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Shared with: ${document.sharedWithNames.join(", ")}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadDocument(Document document) async {
    try {
      final url = await widget.apiService.getDocumentDownloadUrl(document.id);
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading document: ${e.toString()}')),
      );
    }
  }

  Future<void> _showShareDocumentDialog(Document document) async {
    if (_employees == null || _employees!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No employees available to share with')),
      );
      return;
    }
    
    final selectedEmployees = <int>[];
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Share Document'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _employees!.length,
              itemBuilder: (context, index) {
                final employee = _employees![index];
                final isAlreadyShared = document.sharedWith.contains(employee.userId);
                
                return CheckboxListTile(
                  title: Text(employee.fullName),
                  subtitle: Text(employee.position),
                  value: isAlreadyShared || selectedEmployees.contains(employee.userId),
                  onChanged: isAlreadyShared
                      ? null
                      : (value) {
                          setState(() {
                            if (value == true) {
                              selectedEmployees.add(employee.userId);
                            } else {
                              selectedEmployees.remove(employee.userId);
                            }
                          });
                        },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedEmployees.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _shareDocument(document, selectedEmployees);
                    },
              child: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareDocument(Document document, List<int> employeeIds) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await widget.apiService.shareDocument(document.id, employeeIds);
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document shared successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to share document: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(Document document) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDocument(document);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(Document document) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await widget.apiService.deleteDocument(document.id);
      
      setState(() {
        _documents!.removeWhere((doc) => doc.id == document.id);
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to delete document: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _showUploadDocumentDialog() async {
    // This would typically use a file picker plugin
    // For simplicity, we'll just show a dialog with text fields
    
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Document'),
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
              ElevatedButton.icon(
                onPressed: () {
                  // This would typically open a file picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File picker would open here')),
                  );
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Select File'),
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
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document upload functionality would be implemented here')),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
  IconData _getFileIcon(Document document) {
    if (document.isImage) return Icons.image;
    if (document.isPdf) return Icons.picture_as_pdf;
    if (document.isDocument) return Icons.description;
    return Icons.insert_drive_file;
  }
