import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';

class StorageService {
  // --- АККАУНТТАРМЕН ЖҰМЫС ---

  Future<void> saveUser(UserAccount user) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "user_data_${user.login}";
    
    await prefs.setString(key, jsonEncode({
      'login': user.login,
      'password': user.password,
      'progress': user.progress,
      'xp': user.xp,
    }));
    
    await prefs.setString('current_active_user', user.login);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('current_active_user');
  }

  Future<UserAccount?> loadUser() async {
    return await loadActiveUser();
  }

  Future<UserAccount?> getUser(String login) async {
    final prefs = await SharedPreferences.getInstance();
    String key = "user_data_$login";
    final data = prefs.getString(key);
    
    if (data != null) {
      final map = jsonDecode(data);
      return UserAccount(
        login: map['login'],
        password: map['password'] ?? "",
        progress: map['progress'] ?? 1,
        xp: map['xp'] ?? 0,
      );
    }
    return null;
  }

  Future<UserAccount?> loadActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('current_active_user');
    if (login != null) {
      return await getUser(login);
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_active_user');
  }

  // --- ЧАТ ТАРИХЫ (ai_chat_screen.dart үшін) ---

  Future<void> saveChatHistory(List<dynamic> history) async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('current_active_user') ?? 'guest';
    await prefs.setString('chat_history_$login', jsonEncode(history));
  }

  Future<List<dynamic>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('current_active_user') ?? 'guest';
    final data = prefs.getString('chat_history_$login');
    if (data != null) {
      return jsonDecode(data);
    }
    return [];
  }

  // --- КОМПИЛЯТОР ЖӘНЕ КОДТАР (compiler_screen.dart үшін) ---

  Future<void> saveSavedCodes(List<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('current_active_user') ?? 'guest';
    await prefs.setStringList('saved_codes_$login', codes);
  }

  Future<List<String>> loadSavedCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('current_active_user') ?? 'guest';
    return prefs.getStringList('saved_codes_$login') ?? [];
  }

  // ТҮЗЕЛДІ: Енді Map<String, String> қабылдайды (код пен нәтижені сақтау үшін)
  Future<void> saveCompilerDraft(Map<String, String> draftData) async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('current_active_user') ?? 'guest';
    await prefs.setString('compiler_draft_$login', jsonEncode(draftData));
  }

  // ТҮЗЕЛДІ: Енді Map<String, String> қайтарады
  Future<Map<String, String>> loadCompilerDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('current_active_user') ?? 'guest';
    final data = prefs.getString('compiler_draft_$login');
    if (data != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(data);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  // Прогресті жаңарту
  Future<void> updateProgress(String login, int newProgress, int addedXp) async {
    final user = await getUser(login);
    if (user != null) {
      user.progress = newProgress;
      user.xp += addedXp;
      await saveUser(user);
    }
  }
}