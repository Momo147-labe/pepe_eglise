class ChurchModel {
  final int? id;
  final String name;
  final String address;
  final String email;
  final String phone;

  ChurchModel({
    this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'email': email,
      'phone': phone,
    };
  }

  factory ChurchModel.fromMap(Map<String, dynamic> map) {
    return ChurchModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      email: map['email'],
      phone: map['phone'],
    );
  }
}
