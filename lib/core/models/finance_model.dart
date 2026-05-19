class FinanceModel {
  final int? id;
  final String date;
  final String entity;
  final String amount;
  final String type;
  final String description;
  final int? memberId;

  FinanceModel({
    this.id,
    required this.date,
    required this.entity,
    required this.amount,
    required this.type,
    required this.description,
    this.memberId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'entity': entity,
      'amount': amount,
      'type': type,
      'description': description,
      'member_id': memberId,
    };
  }

  factory FinanceModel.fromMap(Map<String, dynamic> map) {
    return FinanceModel(
      id: map['id'],
      date: map['date'],
      entity: map['entity'],
      amount: map['amount'],
      type: map['type'],
      description: map['description'],
      memberId: map['member_id'],
    );
  }
}
