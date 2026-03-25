// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';

class StorageService {
  static const String _keyLogin = 'login';
  static const String _keyProgress = 'progress';
  static const String _keyXp = 'xp';

  // Пайдаланушы деректерін сақтау
  Future<void> saveUser(UserAccount user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLogin, user.login);
    await prefs.setInt(_keyProgress, user.progress);
    await prefs.setInt(_keyXp, user.xp);
  }

  // Сақталған пайдаланушыны жүктеу
  Future<UserAccount?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString(_keyLogin);
    
    if (login != null) {
      return UserAccount(
        login: login,
        password: "", // Парольді сақтамаймыз
        progress: prefs.getInt(_keyProgress) ?? 1,
        xp: prefs.getInt(_keyXp) ?? 0,
      );
    }
    return null;
  }

  // Деректерді өшіру (Шығу)
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}