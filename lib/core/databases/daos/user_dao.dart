import 'package:sqflite/sqflite.dart';
import '../../models/user_model.dart';
import '../schemas/user_schema.dart';

class UserDao {
  final Database db;

  UserDao(this.db);

  Future<int> insertUser(UserModel user) async {
    return await db.insert(UserSchema.tableName, user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final List<Map<String, dynamic>> maps = await db.query(
      UserSchema.tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final List<Map<String, dynamic>> maps = await db.query(
      UserSchema.tableName,
    );
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> updatePasswordByEmail(
    String email,
    String newPasswordHash,
  ) async {
    return await db.update(
      UserSchema.tableName,
      {'password_hash': newPasswordHash},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}
