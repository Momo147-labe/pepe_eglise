import 'package:sqflite/sqflite.dart';
import '../../models/member_model.dart';
import '../schemas/member_schema.dart';

class MemberDao {
  final Database db;

  MemberDao(this.db);

  Future<int> insertMember(MemberModel member) async {
    return await db.insert(MemberSchema.tableName, member.toMap());
  }

  Future<List<MemberModel>> getAllMembers() async {
    final List<Map<String, dynamic>> maps = await db.query(
      MemberSchema.tableName,
    );
    return List.generate(maps.length, (i) {
      return MemberModel.fromMap(maps[i]);
    });
  }

  Future<int> updateMember(MemberModel member) async {
    return await db.update(
      MemberSchema.tableName,
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    return await db.delete(
      MemberSchema.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getMemberCount() async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${MemberSchema.tableName}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getNewMembersCount(DateTime since) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${MemberSchema.tableName} WHERE joined_at >= ?',
      [since.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getGenderCount(String gender) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${MemberSchema.tableName} WHERE gender = ?',
      [gender],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<MemberModel>> getRecentMembers(int limit) async {
    final List<Map<String, dynamic>> maps = await db.query(
      MemberSchema.tableName,
      orderBy: 'joined_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return MemberModel.fromMap(maps[i]);
    });
  }

  Future<Map<String, int>> getMemberStatusDistribution() async {
    final result = await db.rawQuery(
      'SELECT member_status, COUNT(*) as count FROM ${MemberSchema.tableName} GROUP BY member_status',
    );
    return {
      for (var row in result)
        (row['member_status'] as String): (row['count'] as int),
    };
  }

  Future<int> getYearlyGrowth(int year) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${MemberSchema.tableName} WHERE joining_year = ?',
      [year],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
