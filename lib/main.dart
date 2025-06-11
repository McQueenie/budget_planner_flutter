import 'package:flutter/material.dart';
import 'package:budget_planner_flutter/services/database_service.dart';
import 'package:budget_planner_flutter/screens/home_screen.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    databaseFactory = databaseFactoryFfi;
  }
  
  await DatabaseService.instance.initDatabase();
  runApp(const BudgetPlannerApp());
}

class BudgetPlannerApp extends StatelessWidget {
  const BudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Planner',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A4A4A),
          secondary: Color(0xFF666666),
          surface: Color(0xFF111111),
          background: Color(0xFF000000),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFFE5E5E5),
          onBackground: Color(0xFFE5E5E5),
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        cardColor: const Color(0xFF111111),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF666666), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A4A4A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2A2A2A),
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Color(0xFF4A4A4A),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}