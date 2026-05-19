class EventModel {
  final int? id;
  final String title;
  final String date;
  final String location;
  final String description;
  final String? imagePath;
  final double? budget;
  final int? expectedAttendees;
  final String? frequency; // 'once', 'weekly', 'monthly', 'yearly'
  final String? endDate;

  EventModel({
    this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    this.imagePath,
    this.budget,
    this.expectedAttendees,
    this.frequency = 'once',
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'location': location,
      'description': description,
      'imagePath': imagePath,
      'budget': budget,
      'expectedAttendees': expectedAttendees,
      'frequency': frequency,
      'endDate': endDate,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'],
      budget: map['budget']?.toDouble(),
      expectedAttendees: map['expectedAttendees'],
      frequency: map['frequency'],
      endDate: map['endDate'],
    );
  }
}
