import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'documents_screen.dart';

class ManagerDocumentsScreen extends StatefulWidget {
  final ApiService apiService;
  
  const ManagerDocumentsScreen({
    Key? key, 
    required this.apiService,
  }) : super(key: key);

  @override
  _ManagerDocumentsScreenState createState() => _ManagerDocumentsScreenState();
}

class _ManagerDocumentsScreenState extends State<ManagerDocumentsScreen> {
  List<Document>? _documents;
  List<Employee>? _employees;
  bool _isLoading = true;
  String? _error;
  
  // For filtering
  String _searchQuery = '';
  String _filterBy = 'All';
  List<String> _filterOptions = ['All', 'My Documents', 'Shared With Me'];
  
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
      final employees = await widget.apiService.getEmployees();

      setState(() {
        _documents = documents;
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Document> get _filteredDocuments {
    if (_documents == null) return [];
    
    return _documents!.where((doc) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          doc.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.uploadedByName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Apply category filter
      bool matchesFilter;
      switch (_filterBy) {
        case 'My Documents':
          matchesFilter = doc.uploadedBy == widget.apiService.userId;
          break;
        case 'Shared With Me':
          matchesFilter = doc.sharedWith.contains(widget.apiService.userId);
          break;
        case 'All':
        default:
          matchesFilter = true;
          break;
      }
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Management'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    _buildSearchAndFilterBar(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: _filteredDocuments.isEmpty
                            ? const Center(child: Text('No documents found'))
                            : ListView.builder(
                                itemCount: _filteredDocuments.length,
                                itemBuilder: (context, index) {
                                  return _buildDocumentCard(_filteredDocuments[index]);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentsScreen(
                apiService: widget.apiService,
                isManager: true,
              ),
            ),
          ).then((_) => _loadData());
        },
        tooltip: 'Upload Document',
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search documents...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: _filterBy == filter,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filterBy = filter;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.asset(
          document.fileIcon,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.insert_drive_file, size: 40);
          },
        ),
        title: Text(document.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document.description.isNotEmpty) ...[
              Text(document.description),
              const SizedBox(height: 4),
            ],
            Text('Uploaded by: ${document.uploadedByName}'),
            Text('Date: ${document.uploadDate}'),
            if (document.sharedWithNames.isNotEmpty)
              Text('Shared with: ${document.sharedWithNames.join(", ")}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'view':
                _viewDocument(document);
                break;
              case 'edit':
                _navigateToEditDocument(document);
                break;
              case 'share':
                _navigateToShareDocument(document);
                break;
              case 'delete':
                _confirmDeleteDocument(document);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewDocument(Document document) {
    // Navigate to document viewer or download
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentsScreen(
          apiService: widget.apiService,
          isManager: true,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToEditDocument(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentsScreen(
          apiService: widget.apiService,
          isManager: true,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToShareDocument(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentsScreen(
          apiService: widget.apiService,
          isManager: true,
        ),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _confirmDeleteDocument(Document document) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${document.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                setState(() {
                  _isLoading = true;
                });
                
                await widget.apiService.deleteDocument(document.id);
                await _loadData();
                
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
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
