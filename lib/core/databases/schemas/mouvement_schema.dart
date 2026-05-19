class MouvementSchema {
  static const String tableName = 'mouvements';
  static const String memberRelationTable = 'mouvement_members';

  static const String createTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      description TEXT,
      responsable_id INTEGER,
      date_creation TEXT,
      FOREIGN KEY (responsable_id) REFERENCES members (id)
    )
  ''';

  static const String createRelationTableQuery =
      '''
    CREATE TABLE IF NOT EXISTS $memberRelationTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      membre_id INTEGER NOT NULL,
      mouvement_id INTEGER NOT NULL,
      FOREIGN KEY (membre_id) REFERENCES members (id) ON DELETE CASCADE,
      FOREIGN KEY (mouvement_id) REFERENCES $tableName ON DELETE CASCADE
    )
  ''';
}
