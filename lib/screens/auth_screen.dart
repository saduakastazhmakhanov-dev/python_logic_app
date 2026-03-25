import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../services/storage_service.dart';
import 'main_navigation.dart';

// Тек бірінші рет кіретіндерге арналған уақытша дерек
List<UserAccount> mockAccounts = [UserAccount(login: "admin", password: "123456")];
UserAccount? globalCurrentUser;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passController = TextEditingController(); 
  final _storage = StorageService();
  bool _isLoginMode = true;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String login = _loginController.text.trim();
    String password = _passController.text.trim();

    if (_isLoginMode) {
      // 1. Жадтан деректі жүктеп көреміз
      final savedUser = await _storage.loadUser();
      
      // 2. Егер жадта осы атпен адам болса — соны қолданамыз (Прогресс осы жерде сақталады)
      if (savedUser != null && savedUser.login == login) {
        globalCurrentUser = savedUser;
      } else {
        // 3. Егер жадта жоқ болса, mock тізімнен іздейміз
        try {
          final user = mockAccounts.firstWhere(
            (a) => a.login == login && a.password == password,
          );
          globalCurrentUser = user;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Пайдаланушы табылмады немесе пароль қате!"), backgroundColor: Colors.red),
          );
          return;
        }
      }
      
      // Жүйеге кіргенде деректі қайта сақтап қоямыз
      await _storage.saveUser(globalCurrentUser!);
      _goToMain();

    } else {
      // ТІРКЕЛУ: Жаңа пайдаланушы жасау
      final newUser = UserAccount(login: login, password: password, progress: 1, xp: 0);
      globalCurrentUser = newUser;
      await _storage.saveUser(newUser); 
      _goToMain();
    }
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (c) => const MainNavigation()),
    );
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
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.terminal, size: 100, color: Color(0xFFFFD600)),
                const SizedBox(height: 20),
                const Text("PYTHON LOGIC", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.white)),
                const Text("Болашақ бағдарламалаушы мектебі", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 50),
                TextFormField(
                  controller: _loginController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Логин", 
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.person, color: Colors.amber)
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? "Логинді жазыңыз" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Пароль (6-12 символ)',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock, color: Colors.amber),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Парольді жазыңыз';
                    if (value.length < 6) return 'Пароль тым қысқа';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: Text(_isLoginMode ? "КІРУ" : "ТІРКЕЛУ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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