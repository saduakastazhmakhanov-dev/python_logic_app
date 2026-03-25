// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../services/storage_service.dart';
import 'main_navigation.dart';

// Уақытша деректер базасы
List<UserAccount> mockAccounts = [UserAccount(login: "admin", password: "123456")];
UserAccount? globalCurrentUser;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>(); // Валидация үшін қажет
  final _loginController = TextEditingController();
  final _passController = TextEditingController(); // _passwordController емес, осыны қолданамыз
  final _storage = StorageService();
  bool _isLoginMode = true;

  void _submit() async {
    // 1. Форманы тексеру (6-12 символ осы жерде тексеріледі)
    if (!_formKey.currentState!.validate()) return;

    String login = _loginController.text.trim();
    String password = _passController.text.trim();

    if (_isLoginMode) {
      // КІРУ ЛОГИКАСЫ
      try {
        final user = mockAccounts.firstWhere(
          (a) => a.login == login && a.password == password,
        );
        globalCurrentUser = user;
        await _storage.saveUser(user); // Сессияны сақтау
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const MainNavigation()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Логин немесе пароль қате!"), backgroundColor: Colors.red),
        );
      }
    } else {
      // ТІРКЕЛУ ЛОГИКАСЫ
      if (mockAccounts.any((a) => a.login == login)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Бұл логин бос емес!"), backgroundColor: Colors.orange),
        );
      } else {
        final newUser = UserAccount(login: login, password: password);
        mockAccounts.add(newUser);
        globalCurrentUser = newUser;
        await _storage.saveUser(newUser); // Жаңа пайдаланушыны сақтау
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const MainNavigation()),
        );
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form( // Валидация жұмыс істеуі үшін Form-мен орадық
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.terminal, size: 100, color: Color(0xFFFFD600)),
                const SizedBox(height: 20),
                const Text("PYTHON LOGIC", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const Text("Болашақ бағдарламалаушы мектебі", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 50),
                
                // ЛОГИН ӨРІСІ
                TextFormField(
                  controller: _loginController,
                  decoration: const InputDecoration(labelText: "Логин", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  validator: (value) => (value == null || value.isEmpty) ? "Логинді жазыңыз" : null,
                ),
                const SizedBox(height: 15),
                
                // ПАРОЛЬ ӨРІСІ (6-12 СИМВОЛ ШЕКТЕУІМЕН)
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль (6-12 символ)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Парольді жазыңыз';
                    if (value.length < 6) return 'Пароль тым қысқа (кемінде 6 символ)';
                    if (value.length > 12) return 'Пароль тым ұзын (максимум 12 символ)';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: Text(_isLoginMode ? "КІРУ" : "ТІРКЕЛУ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                
                TextButton(
                  onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                  child: Text(_isLoginMode ? "Жаңа аккаунт жасау (Тіркелу)" : "Аккаунтым бар (Кіру)", style: const TextStyle(color: Colors.amber)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}