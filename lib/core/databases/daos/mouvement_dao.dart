import 'package:sqflite/sqflite.dart';
import 'package:eglise_labe/core/databases/schemas/mouvement_schema.dart';
import 'package:eglise_labe/core/databases/schemas/member_schema.dart';
import 'package:eglise_labe/core/models/mouvement_model.dart';
import 'package:eglise_labe/core/models/member_model.dart';

class MouvementDao {
  final Database db;

  MouvementDao(this.db);

  Future<int> insertMouvement(MouvementModel mouvement) async {
    return await db.insert(MouvementSchema.tableName, mouvement.toMap());
  }

  Future<int> updateMouvement(MouvementModel mouvement) async {
    return await db.update(
      MouvementSchema.tableName,
      mouvement.toMap(),
      where: 'id = ?',
      whereArgs: [mouvement.id],
    );
  }

  Future<int> deleteMouvement(int id) async {
    return await db.delete(
      MouvementSchema.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MouvementModel>> getAllMouvements() async {
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.*, memb.full_name as responsable_name,
      (SELECT COUNT(*) FROM ${MouvementSchema.memberRelationTable} mr WHERE mr.mouvement_id = m.id) as member_count
      FROM ${MouvementSchema.tableName} m
      LEFT JOIN ${MemberSchema.tableName} memb ON m.responsable_id = memb.id
    ''');
    return List.generate(maps.length, (i) => MouvementModel.fromMap(maps[i]));
  }

  Future<List<MouvementModel>> searchMouvements(String query) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT m.*, memb.full_name as responsable_name,
      (SELECT COUNT(*) FROM ${MouvementSchema.memberRelationTable} mr WHERE mr.mouvement_id = m.id) as member_count
      FROM ${MouvementSchema.tableName} m
      LEFT JOIN ${MemberSchema.tableName} memb ON m.responsable_id = memb.id
      WHERE m.nom LIKE ? OR m.description LIKE ?
    ''',
      ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => MouvementModel.fromMap(maps[i]));
  }

  // Member Management in Mouvements
  Future<int> addMemberToMouvement(int membreId, int mouvementId) async {
    return await db.insert(MouvementSchema.memberRelationTable, {
      'membre_id': membreId,
      'mouvement_id': mouvementId,
    });
  }

  Future<int> removeMemberFromMouvement(int membreId, int mouvementId) async {
    return await db.delete(
      MouvementSchema.memberRelationTable,
      where: 'membre_id = ? AND mouvement_id = ?',
      whereArgs: [membreId, mouvementId],
    );
  }

  Future<List<MemberModel>> getMouvementMembers(int mouvementId) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT m.* FROM ${MemberSchema.tableName} m
      JOIN ${MouvementSchema.memberRelationTable} mr ON m.id = mr.membre_id
      WHERE mr.mouvement_id = ?
    ''',
      [mouvementId],
    );
    return List.generate(maps.length, (i) => MemberModel.fromMap(maps[i]));
  }

  // Statistics
  Future<int> getMouvementCount() async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${MouvementSchema.tableName}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, dynamic>> getLargestMouvement() async {
    final result = await db.rawQuery('''
      SELECT m.nom, (SELECT COUNT(*) FROM ${MouvementSchema.memberRelationTable} mr WHERE mr.mouvement_id = m.id) as count
      FROM ${MouvementSchema.tableName} m
      ORDER BY count DESC LIMIT 1
    ''');
    if (result.isEmpty) return {'nom': 'N/A', 'count': 0};
    return result.first;
  }
}
