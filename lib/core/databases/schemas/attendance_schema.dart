class AttendanceSchema {
  static const String tableName = 'attendances';

  static const String createTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      activity_id INTEGER NOT NULL,
      member_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      status TEXT NOT NULL,
      FOREIGN KEY (activity_id) REFERENCES activities (id),
      FOREIGN KEY (member_id) REFERENCES members (id)
    )
  ''';
}
