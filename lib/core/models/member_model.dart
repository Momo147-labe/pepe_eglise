class MemberModel {
  final int? id;
  final String fullName;
  final String phone;
  final String gender;
  final String groupName;
  final String maritalStatus;
  final String memberStatus;
  final String joinedAt;
  final String? birthDate;
  final int? joiningYear;
  final int? childrenCount;
  final String? imagePath;
  final String? quartier;
  final String? birthPlace;

  MemberModel({
    this.id,
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.groupName,
    required this.maritalStatus,
    required this.memberStatus,
    required this.joinedAt,
    this.birthDate,
    this.joiningYear,
    this.childrenCount,
    this.imagePath,
    this.quartier,
    this.birthPlace,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'gender': gender,
      'group_name': groupName,
      'marital_status': maritalStatus,
      'member_status': memberStatus,
      'joined_at': joinedAt,
      'birth_date': birthDate,
      'joining_year': joiningYear,
      'children_count': childrenCount,
      'image_path': imagePath,
      'quartier': quartier,
      'birth_place': birthPlace,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'],
      fullName: map['full_name'],
      phone: map['phone'],
      gender: map['gender'] ?? 'M',
      groupName: map['group_name'],
      maritalStatus: map['marital_status'],
      memberStatus: map['member_status'],
      joinedAt: map['joined_at'],
      birthDate: map['birth_date'],
      joiningYear: map['joining_year'],
      childrenCount: map['children_count'],
      imagePath: map['image_path'],
      quartier: map['quartier'],
      birthPlace: map['birth_place'],
    );
  }
}
