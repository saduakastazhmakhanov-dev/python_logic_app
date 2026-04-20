import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/storage_service.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  // 1. Flutter мен Firebase-ті іске қосу
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB4OyRnNxVfGj8Vk_YI1YORdHW4KpKNc38",
        appId: "1:113875570782:web:ebb64e400d1b609a3224cf",
        messagingSenderId: "113875570782",
        projectId: "python-logic",
        databaseURL: "https://python-logic-default-rtdb.firebaseio.com",
        storageBucket: "python-logic.firebasestorage.app",
        authDomain: "python-logic.firebaseapp.com",
      ),
    );
  } catch (e) {
    debugPrint("Firebase инициализация қатесі: $e");
  }

  // 2. Пайдаланушы сессиясын тексеру
  final storage = StorageService();
  
  // Firebase арқылы қазіргі кіріп тұрған қолданушыны алу
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser != null) {
    // Егер Firebase-те сессия болса, оның деректерін Storage-ден жүктейміз
    globalCurrentUser = await storage.loadUser();
  } else {
    // Сессия болмаса, жадты тазалаймыз
    globalCurrentUser = null;
  }

  runApp(PythonEduApp(hasUser: firebaseUser != null && globalCurrentUser != null));
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
          centerTitle: true,
          elevation: 0,
        ),
      ),
      // Пайдаланушы кірген болса MainNavigation-ге, болмаса AuthScreen-ге жіберу
      home: hasUser ? const MainNavigation() : const AuthScreen(),
    );
  }
}