import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// ✅ STOCKAGE SÉCURISÉ dans AppData (Windows)
Future<String> getAppStorageDirectory() async {
  late String basePath;

  if (Platform.isWindows) {
    // ✅ Windows : AppData\Local (pas de droits admin requis)
    final appData = await getApplicationSupportDirectory();
    basePath = join(appData.path, 'com.fodemomo.eglise_labe');
  } else if (Platform.isLinux) {
    // ✅ Linux : ~/.local/share
    final appData = await getApplicationSupportDirectory();
    basePath = join(appData.path, 'eglise_labe');
  } else {
    // ✅ Fallback
    final appData = await getApplicationSupportDirectory();
    basePath = appData.path;
  }

  // ✅ Créer le dossier si nécessaire
  final directory = Directory(basePath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  return basePath;
}

Future<String> getDatabasePath() async {
  final basePath = await getAppStorageDirectory();
  final dbPath = join(basePath, 'eglise_labe.db');

  // 🔍 Log pour debug (safe en production)
  print('SQLite DB PATH => $dbPath');

  return dbPath;
}
