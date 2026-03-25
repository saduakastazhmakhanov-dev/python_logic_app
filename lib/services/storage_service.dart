import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _keyLogin = 'login';
  static const String _keyProgress = 'progress';
  static const String _keyXp = 'xp';

  String _chatHistoryKey(String login) => 'chat_history_$login';
  String _savedCodesKey(String login) => 'saved_codes_$login';

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

  // =========================
  // AI Chat history (per user)
  // =========================

  Future<void> saveChatHistory(String login, List<Message> chat) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = messagesToJson(chat);
    await prefs.setString(_chatHistoryKey(login), raw);
  }

  Future<List<Message>> loadChatHistory(String login) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chatHistoryKey(login));
    if (raw == null || raw.trim().isEmpty) return const [];
    return messagesFromJson(raw);
  }

  // =========================
  // Saved Python snippets (per user)
  // =========================

  Future<void> saveSavedCodes(String login, List<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    // Локально храним как JSON строку.
    await prefs.setString(_savedCodesKey(login), _encodeStringList(codes));
  }

  Future<List<String>> loadSavedCodes(String login) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedCodesKey(login));
    if (raw == null || raw.trim().isEmpty) return const [];
    return _decodeStringList(raw);
  }

  String _encodeStringList(List<String> values) {
    return jsonEncode(values);
  }

  List<String> _decodeStringList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}