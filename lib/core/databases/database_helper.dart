import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_path.dart';
import 'schemas/user_schema.dart';
import 'daos/user_dao.dart';
import 'schemas/member_schema.dart';
import 'daos/member_dao.dart';
import 'schemas/activity_schema.dart';
import 'daos/activity_dao.dart';
import 'schemas/event_schema.dart';
import 'daos/event_dao.dart';
import 'schemas/finance_schema.dart';
import 'daos/finance_dao.dart';
import 'schemas/mouvement_schema.dart';
import 'daos/mouvement_dao.dart';
import 'schemas/church_schema.dart';
import 'daos/church_dao.dart';
import 'schemas/attendance_schema.dart';
import 'daos/attendance_dao.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static const int _databaseVersion = 11;
  static Database? _database;
  // Prevents concurrent openDatabase calls (race condition fix)
  static Completer<Database>? _dbCompleter;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_dbCompleter != null) return _dbCompleter!.future;
    _dbCompleter = Completer<Database>();
    try {
      _database = await _initDatabase();
      _dbCompleter!.complete(_database!);
    } catch (e) {
      _dbCompleter!.completeError(e);
      _dbCompleter = null;
      rethrow;
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasePath();
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTables(db);
    }
    if (oldVersion < 3) {
      // Add gender column to members table if it doesn't exist
      try {
        await db.execute(
          'ALTER TABLE members ADD COLUMN gender TEXT DEFAULT "M"',
        );
      } catch (e) {
        // Column might already exist if table was created in v3
      }
    }
    if (oldVersion < 4) {
      await db.execute(MouvementSchema.createTableQuery);
      await db.execute(MouvementSchema.createRelationTableQuery);
    }
    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE members ADD COLUMN birth_date TEXT');
        await db.execute('ALTER TABLE members ADD COLUMN joining_year INTEGER');
        await db.execute(
          'ALTER TABLE members ADD COLUMN children_count INTEGER',
        );
        await db.execute('ALTER TABLE members ADD COLUMN image_path TEXT');
      } catch (e) {
        // Columns might already exist
      }
    }
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE members ADD COLUMN quartier TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE members ADD COLUMN birth_place TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
    if (oldVersion < 8) {
      await db.execute(ChurchSchema.createTableQuery);
    }
    if (oldVersion < 10) {
      try {
        await db.execute('ALTER TABLE events ADD COLUMN imagePath TEXT');
        await db.execute('ALTER TABLE events ADD COLUMN budget REAL');
        await db.execute(
          'ALTER TABLE events ADD COLUMN expectedAttendees INTEGER',
        );
        await db.execute('ALTER TABLE events ADD COLUMN frequency TEXT');
        await db.execute('ALTER TABLE events ADD COLUMN endDate TEXT');
      } catch (e) {
        // Columns might already exist
      }
    }
    if (oldVersion < 11) {
      try {
        await db.execute('ALTER TABLE activities ADD COLUMN description TEXT');
        await db.execute('ALTER TABLE activities ADD COLUMN location TEXT');
        await db.execute('ALTER TABLE activities ADD COLUMN imagePath TEXT');
      } catch (e) {
        // Columns might already exist
      }
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute(UserSchema.createTableQuery);
    await db.execute(MemberSchema.createTableQuery);
    await db.execute(ActivitySchema.createTableQuery);
    await db.execute(EventSchema.createTableQuery);
    await db.execute(FinanceSchema.createTableQuery);
    await db.execute(MouvementSchema.createTableQuery);
    await db.execute(MouvementSchema.createRelationTableQuery);
    await db.execute(ChurchSchema.createTableQuery);
    await db.execute(AttendanceSchema.createTableQuery);
  }

  // DAO Accessors
  Future<UserDao> get userDao async {
    final db = await database;
    return UserDao(db);
  }

  Future<MemberDao> get memberDao async {
    final db = await database;
    return MemberDao(db);
  }

  Future<ActivityDao> get activityDao async {
    final db = await database;
    return ActivityDao(db);
  }

  Future<EventDao> get eventDao async {
    final db = await database;
    return EventDao(db);
  }

  Future<FinanceDao> get financeDao async {
    final db = await database;
    return FinanceDao(db);
  }

  Future<MouvementDao> get mouvementDao async {
    final db = await database;
    return MouvementDao(db);
  }

  Future<ChurchDao> get churchDao async {
    final db = await database;
    return ChurchDao(db);
  }

  Future<AttendanceDao> get attendanceDao async {
    final db = await database;
    return AttendanceDao(db);
  }
}
