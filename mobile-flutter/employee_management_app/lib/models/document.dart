import 'package:flutter/material.dart';

class Document {
  final int id;
  final String title;
  final String description;
  final String fileName;
  final String fileUrl;
  final int uploadedById;
  final String uploadedByName;
  final List<int> sharedWith;
  final List<String> sharedWithNames;
  final String createdAt;
  final String updatedAt;

  Document({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedById,
    required this.uploadedByName,
    required this.sharedWith,
    required this.sharedWithNames,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'] ?? '',
      uploadedById: json['uploaded_by_id'],
      uploadedByName: json['uploaded_by_name'] ?? '',
      sharedWith: List<int>.from(json['shared_with'] ?? []),
      sharedWithNames: List<String>.from(json['shared_with_names'] ?? []),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'file_name': fileName,
      'file_url': fileUrl,
      'uploaded_by_id': uploadedById,
      'uploaded_by_name': uploadedByName,
      'shared_with': sharedWith,
      'shared_with_names': sharedWithNames,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  bool get isImage {
    final ext = fileExtension;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  bool get isPdf {
    return fileExtension == 'pdf';
  }

  bool get isDocument {
    final ext = fileExtension;
    return ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'rtf', 'odt', 'ods', 'odp'].contains(ext);
  }
  
  // Additional getters to fix errors
  int get uploadedBy => uploadedById;
  
  IconData get fileIcon {
    if (isImage) return Icons.image;
    if (isPdf) return Icons.picture_as_pdf;
    if (isDocument) return Icons.description;
    return Icons.insert_drive_file;
  }
  
  String get uploadDate {
    try {
      return createdAt.split('T')[0];
    } catch (e) {
      return createdAt;
    }
  }
  
  String get fileType {
    if (isImage) return 'Image';
    if (isPdf) return 'PDF';
    if (isDocument) return 'Document';
    return fileExtension.toUpperCase();
  }
}
