// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../services/storage_service.dart';
import 'main_navigation.dart';

// Уақытша деректер базасы (main.dart-тан көшірілді)
List<UserAccount> mockAccounts = [UserAccount(login: "admin", password: "123")];
UserAccount? globalCurrentUser; // Жаһандық айнымалы

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginController = TextEditingController();
  final _passController = TextEditingController();
  final _storage = StorageService();
  bool _isLoginMode = true;

  void _submit() async {
    String login = _loginController.text.trim();
    String password = _passController.text.trim();
    
    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Барлық өрісті толтырыңыз")));
      return;
    }

    if (_isLoginMode) {
      // Кіру логикасы
      try {
        final user = mockAccounts.firstWhere((a) => a.login == login && a.password == password);
        globalCurrentUser = user;
        await _storage.saveUser(user); // Сақтау
        if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const MainNavigation()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Логин немесе пароль қате!"), backgroundColor: Colors.red,));
      }
    } else {
      // Тіркелу логикасы
      if (mockAccounts.any((a) => a.login == login)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Бұл логин бос емес!"), backgroundColor: Colors.orange,));
      } else {
        final newUser = UserAccount(login: login, password: password);
        mockAccounts.add(newUser);
        globalCurrentUser = newUser;
        await _storage.saveUser(newUser); // Сақтау
        if (!mounted) return;
        Navigator.pushReplacement(
  context, 
  MaterialPageRoute(builder: (c) => const MainNavigation())
);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.terminal, size: 100, color: Color(0xFFFFD600)),
              const SizedBox(height: 20),
              const Text("PYTHON LOGIC", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3)),
              const Text("Болашақ бағдарламалаушы мектебі", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 50),
              TextField(
                controller: _loginController, 
                decoration: const InputDecoration(labelText: "Логин", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passController, 
                obscureText: true, 
                decoration: const InputDecoration(labelText: "Құпия сөз", border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60), 
                  backgroundColor: Colors.amber, 
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _submit,
                child: Text(_isLoginMode ? "КІРУ" : "ТІРКЕЛУ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode), 
                child: Text(_isLoginMode ? "Жаңа аккаунт жасау (Тіркелу)" : "Аккаунтым бар (Кіру)", style: const TextStyle(color: Colors.amber))
              ),
            ],
          ),
        ),
      ),
    );
  }
}