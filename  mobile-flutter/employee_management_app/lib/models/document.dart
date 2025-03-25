class Document {
  final int? id;
  final String title;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final DateTime uploadDate;
  final int uploadedBy;
  final bool isShared;

  Document({
    this.id,
    required this.title,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.uploadDate,
    required this.uploadedBy,
    required this.isShared,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      fileName: json['file_name'],
      fileType: json['file_type'],
      fileUrl: json['file_url'],
      uploadDate: DateTime.parse(json['upload_date']),
      uploadedBy: json['uploaded_by'],
      isShared: json['is_shared'],
    );
  }
}
