class AttendanceModel {
  final int? id;
  final int activityId;
  final int memberId;
  final String date;
  final String status;

  AttendanceModel({
    this.id,
    required this.activityId,
    required this.memberId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_id': activityId,
      'member_id': memberId,
      'date': date,
      'status': status,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      activityId: map['activity_id'],
      memberId: map['member_id'],
      date: map['date'],
      status: map['status'],
    );
  }
}
