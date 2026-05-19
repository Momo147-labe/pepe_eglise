class EventSchema {
  static const String tableName = 'events';

  static const String createTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      date TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT NOT NULL,
      imagePath TEXT,
      budget REAL,
      expectedAttendees INTEGER,
      frequency TEXT,
      endDate TEXT
    )
  ''';
}
