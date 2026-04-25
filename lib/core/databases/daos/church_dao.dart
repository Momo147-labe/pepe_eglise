import 'package:sqflite/sqflite.dart';
import '../../models/church_model.dart';
import '../schemas/church_schema.dart';

class ChurchDao {
  final Database db;

  ChurchDao(this.db);

  Future<ChurchModel?> getChurchProfile() async {
    final List<Map<String, dynamic>> maps = await db.query(
      ChurchSchema.tableName,
      limit: 1,
    );

    if (maps.isEmpty) {
      // Return default if empty
      return ChurchModel(
        id: 1,
        name: "Église Protestante de Labé",
        address: "Quartier Kouroula, Labé, Guinée",
        email: "contact@egliselabe.org",
        phone: "+224 621 00 00 00",
      );
    }
    return ChurchModel.fromMap(maps.first);
  }

  Future<int> updateChurchProfile(ChurchModel profile) async {
    // Check if exists
    final List<Map<String, dynamic>> maps = await db.query(
      ChurchSchema.tableName,
      limit: 1,
    );

    if (maps.isEmpty) {
      return await db.insert(ChurchSchema.tableName, profile.toMap());
    } else {
      return await db.update(
        ChurchSchema.tableName,
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    }
  }
}
