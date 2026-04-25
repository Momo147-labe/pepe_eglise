class ChurchSchema {
  static const String tableName = 'eglise';

  static const String createTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      email TEXT NOT NULL,
      phone TEXT NOT NULL
    )
  ''';
}
