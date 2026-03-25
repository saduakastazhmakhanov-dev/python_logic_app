import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';

class StorageService {
  static const String _keyLogin = 'login';
  static const String _keyProgress = 'progress';
  static const String _keyXp = 'xp';

  // Пайдаланушы деректерін алғаш рет сақтау (Регистрация/Логин кезінде)
  Future<void> saveUser(UserAccount user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLogin, user.login);
    await prefs.setInt(_keyProgress, user.progress);
    await prefs.setInt(_keyXp, user.xp);
  }

  // ЖАҢА: Сабақ біткенде прогресті жаңарту функциясы
  // Осы функция шақырылмаса, қайта кіргенде бәрі 1-сабақтан басталады
  Future<void> updateProgress(int newProgress, int addedXp) async {
    final prefs = await SharedPreferences.getInstance();
    int currentXp = prefs.getInt(_keyXp) ?? 0;
    
    await prefs.setInt(_keyProgress, newProgress);
    await prefs.setInt(_keyXp, currentXp + addedXp);
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