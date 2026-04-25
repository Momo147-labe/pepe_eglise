class ActivityModel {
  final int? id;
  final String name;
  final String type;
  final String freq;
  final String time;
  final String lead;
  final String? description;
  final String? location;
  final String? imagePath;

  ActivityModel({
    this.id,
    required this.name,
    required this.type,
    required this.freq,
    required this.time,
    required this.lead,
    this.description,
    this.location,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'freq': freq,
      'time': time,
      'lead': lead,
      'description': description,
      'location': location,
      'imagePath': imagePath,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      freq: map['freq'],
      time: map['time'],
      lead: map['lead'],
      description: map['description'],
      location: map['location'],
      imagePath: map['imagePath'],
    );
  }
}
