import 'package:sqflite/sqflite.dart';
import '../../models/activity_model.dart';
import '../schemas/activity_schema.dart';

class ActivityDao {
  final Database db;

  ActivityDao(this.db);

  Future<int> insertActivity(ActivityModel activity) async {
    return await db.insert(ActivitySchema.tableName, activity.toMap());
  }

  Future<List<ActivityModel>> getAllActivities() async {
    final List<Map<String, dynamic>> maps = await db.query(
      ActivitySchema.tableName,
    );
    return List.generate(maps.length, (i) {
      return ActivityModel.fromMap(maps[i]);
    });
  }

  Future<int> updateActivity(ActivityModel activity) async {
    return await db.update(
      ActivitySchema.tableName,
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    return await db.delete(
      ActivitySchema.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getActivityCount() async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${ActivitySchema.tableName}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<ActivityModel>> getRecentActivities(int limit) async {
    final List<Map<String, dynamic>> maps = await db.query(
      ActivitySchema.tableName,
      orderBy: 'id DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return ActivityModel.fromMap(maps[i]);
    });
  }

  Future<List<ActivityModel>> searchActivities(String query) async {
    final List<Map<String, dynamic>> maps = await db.query(
      ActivitySchema.tableName,
      where: 'name LIKE ? OR type LIKE ? OR lead LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return ActivityModel.fromMap(maps[i]);
    });
  }

  Future<Map<String, int>> getCountByType() async {
    final result = await db.rawQuery(
      'SELECT type, COUNT(*) as count FROM ${ActivitySchema.tableName} GROUP BY type',
    );
    Map<String, int> stats = {};
    for (var row in result) {
      stats[row['type'] as String] = row['count'] as int;
    }
    return stats;
  }
}
