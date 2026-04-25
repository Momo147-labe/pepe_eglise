class MemberSchema {
  static const String tableName = 'members';

  static const String createTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      phone TEXT NOT NULL,
      gender TEXT NOT NULL,
      group_name TEXT NOT NULL,
      marital_status TEXT NOT NULL,
      member_status TEXT NOT NULL,
      joined_at TEXT NOT NULL,
      birth_date TEXT,
      joining_year INTEGER,
      children_count INTEGER,
      image_path TEXT,
      quartier TEXT,
      birth_place TEXT
    )
  ''';
}
