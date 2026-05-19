import 'package:sqflite/sqflite.dart';
import '../../models/attendance_model.dart';
import '../schemas/attendance_schema.dart';

class AttendanceDao {
  final Database db;

  AttendanceDao(this.db);

  Future<int> insertAttendance(AttendanceModel attendance) async {
    return await db.insert(
      AttendanceSchema.tableName,
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceModel>> getAttendanceForActivity(
    int activityId,
    String date,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      AttendanceSchema.tableName,
      where: 'activity_id = ? AND date = ?',
      whereArgs: [activityId, date],
    );
    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  Future<int> getAttendanceCount(int activityId, String date) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${AttendanceSchema.tableName} WHERE activity_id = ? AND date = ? AND status = ?',
      [activityId, date, 'Présent'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getAverageAttendance(int activityId) async {
    final result = await db.rawQuery(
      '''
      SELECT AVG(cnt) FROM (
        SELECT COUNT(*) as cnt FROM ${AttendanceSchema.tableName} 
        WHERE activity_id = ? AND status = ? 
        GROUP BY date
      )
      ''',
      [activityId, 'Présent'],
    );
    if (result.isEmpty || result.first.values.first == null) return 0.0;
    return (result.first.values.first as num).toDouble();
  }
}
