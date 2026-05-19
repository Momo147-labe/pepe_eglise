import 'package:sqflite/sqflite.dart';
import '../../models/event_model.dart';
import '../schemas/event_schema.dart';

class EventDao {
  final Database db;

  EventDao(this.db);

  Future<int> insertEvent(EventModel event) async {
    return await db.insert(EventSchema.tableName, event.toMap());
  }

  Future<List<EventModel>> getAllEvents() async {
    final List<Map<String, dynamic>> maps = await db.query(
      EventSchema.tableName,
    );
    return List.generate(maps.length, (i) => EventModel.fromMap(maps[i]));
  }

  Future<int> updateEvent(EventModel event) async {
    return await db.update(
      EventSchema.tableName,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    return await db.delete(
      EventSchema.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getUpcomingEventsCount(DateTime current) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${EventSchema.tableName} WHERE date >= ?',
      [current.toIso8601String().substring(0, 10)],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalBudget() async {
    final result = await db.rawQuery(
      'SELECT SUM(budget) FROM ${EventSchema.tableName}',
    );
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalAttendees() async {
    final result = await db.rawQuery(
      'SELECT SUM(expectedAttendees) FROM ${EventSchema.tableName}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<EventModel>> searchEvents(String query) async {
    final List<Map<String, dynamic>> maps = await db.query(
      EventSchema.tableName,
      where: 'title LIKE ? OR location LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => EventModel.fromMap(maps[i]));
  }
}
