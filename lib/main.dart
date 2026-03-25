// lib/main.dart
import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation.dart';
void main() async {
  // Flutter виджеттерін инициализациялау (сақтау қызметі үшін керек)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Сақталған пайдаланушыны тексеру
  final storage = StorageService();
  final savedUser = await storage.loadUser();
  
  if (savedUser != null) {
    globalCurrentUser = savedUser; // auth_screen.dart-тағы жаһандық айнымалы
  }

  runApp(PythonEduApp(hasUser: savedUser != null));
}

class PythonEduApp extends StatelessWidget {
  final bool hasUser;
  const PythonEduApp({super.key, required this.hasUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Python Logic',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD600), 
          brightness: Brightness.dark
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E), 
          centerTitle: true
        ),
      ),
      // Егер пайдаланушы бұрын кірген болса, бірден Навигацияға өтеді
      home: hasUser ? const MainNavigation() : const AuthScreen(),
    );
  }
}
