class Meeting {
  final int id;
  final String title;
  final String description;
  final String date;
  final String startTime;
  final String endTime;
  final String location;
  final int organizedById;
  final String organizedByName;
  final List<int> attendees;
  final List<String> attendeeNames;
  final String createdAt;
  final String updatedAt;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.organizedById,
    required this.organizedByName,
    required this.attendees,
    required this.attendeeNames,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      location: json['location'] ?? '',
      organizedById: json['organized_by_id'],
      organizedByName: json['organized_by_name'] ?? '',
      attendees: List<int>.from(json['attendees'] ?? []),
      attendeeNames: List<String>.from(json['attendee_names'] ?? []),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'organized_by_id': organizedById,
      'organized_by_name': organizedByName,
      'attendees': attendees,
      'attendee_names': attendeeNames,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get formattedTime => '$startTime - $endTime';
  
  String get formattedAttendees {
    if (attendeeNames.isEmpty) return 'No attendees';
    if (attendeeNames.length <= 2) return attendeeNames.join(', ');
    return '${attendeeNames.take(2).join(', ')} +${attendeeNames.length - 2} more';
  }
  
  String get formattedDateTime => '$date, $startTime - $endTime';
  
  String get organizerName => organizedByName;
  
  List<String> get participantNames => attendeeNames;
}
