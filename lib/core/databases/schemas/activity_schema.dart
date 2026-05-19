class ActivitySchema {
  static const String tableName = 'activities';

  static const String createTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      freq TEXT NOT NULL,
      time TEXT NOT NULL,
      lead TEXT NOT NULL,
      description TEXT,
      location TEXT,
      imagePath TEXT
    )
  ''';
}
