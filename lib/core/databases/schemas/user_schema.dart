class UserSchema {
  static const String tableName = 'users';

  static const String createTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      email TEXT UNIQUE,
      phone TEXT,
      avatar TEXT,
      password_hash TEXT NOT NULL,
      is_blocked INTEGER DEFAULT 0,
      role TEXT NOT NULL,
      permissions TEXT,
      status TEXT DEFAULT 'active',
      last_login TEXT,
      last_activity TEXT,
      login_count INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    )
  ''';
}
