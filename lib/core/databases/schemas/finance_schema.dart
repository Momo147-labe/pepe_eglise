class FinanceSchema {
  static const String tableName = 'finances';

  static const String createTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      entity TEXT NOT NULL,
      amount TEXT NOT NULL,
      type TEXT NOT NULL,
      description TEXT NOT NULL,
      member_id INTEGER
    )
  ''';
}
