import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/features/auth/pages/auth_page.dart';
import 'package:eglise_labe/core/databases/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation SQLite DÉDIÉE pour les plateformes Desktop (Windows, Linux, macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialiser la base de données au démarrage de l'app
  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Église de Labé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.backgroundDark),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const AuthPage(),
    );
  }
}
