// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/hive_datasource.dart';
import 'data/repositories/mission_repository.dart';
import 'presentation/screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize local database
  await HiveDatasource.init();

  // Seed demo data if first launch
  final repo = MissionRepository();
  await repo.seedDemoData();

  runApp(MissionVaultApp(repo: repo));
}

class MissionVaultApp extends StatelessWidget {
  final MissionRepository repo;
  const MissionVaultApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mission Vault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeScreen(repo: repo),
    );
  }
}
