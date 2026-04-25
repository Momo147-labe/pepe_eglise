class MouvementModel {
  final int? id;
  final String nom;
  final String? description;
  final int? responsableId;
  final String? dateCreation;

  // Extra fields for UI convenience (not in DB table directly)
  final String? responsableName;
  final int? memberCount;

  MouvementModel({
    this.id,
    required this.nom,
    this.description,
    this.responsableId,
    this.dateCreation,
    this.responsableName,
    this.memberCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'responsable_id': responsableId,
      'date_creation': dateCreation,
    };
  }

  factory MouvementModel.fromMap(Map<String, dynamic> map) {
    return MouvementModel(
      id: map['id'],
      nom: map['nom'],
      description: map['description'],
      responsableId: map['responsable_id'],
      dateCreation: map['date_creation'],
      responsableName: map['responsable_name'],
      memberCount: map['member_count'],
    );
  }
}

class MouvementMemberModel {
  final int? id;
  final int membreId;
  final int mouvementId;

  MouvementMemberModel({
    this.id,
    required this.membreId,
    required this.mouvementId,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'membre_id': membreId, 'mouvement_id': mouvementId};
  }

  factory MouvementMemberModel.fromMap(Map<String, dynamic> map) {
    return MouvementMemberModel(
      id: map['id'],
      membreId: map['membre_id'],
      mouvementId: map['mouvement_id'],
    );
  }
}
