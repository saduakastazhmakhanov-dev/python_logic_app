import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _keyLogin = 'login';
  // Новое имя, как просил ТЗ.
  static const String _keyIsLoggedIn = 'isLoggedIn';
  // Legacy (оставляю для совместимости со старыми сборками).
  static const String _keyIsLogged = 'is_logged';
  static const String _keyProgress = 'progress';
  static const String _keyXp = 'xp';

  String _progressKeyFor(String login) => 'progress_$login';
  String _xpKeyFor(String login) => 'xp_$login';

  String _chatHistoryKey(String login) => 'chat_history_$login';
  String _savedCodesKey(String login) => 'saved_codes_$login';
  String _compilerDraftKey(String login) => 'compiler_draft_$login';

  // Пайдаланушы деректерін алғаш рет сақтау (Регистрация/Логин кезінде)
  Future<void> saveUser(UserAccount user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLogin, user.login);
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setBool(_keyIsLogged, true); // legacy

    // Храним прогресс/XP привязано к логину, но оставляем старые ключи для обратной совместимости.
    await prefs.setInt(_progressKeyFor(user.login), user.progress);
    await prefs.setInt(_xpKeyFor(user.login), user.xp);

    await prefs.setInt(_keyProgress, user.progress); // legacy
    await prefs.setInt(_keyXp, user.xp); // legacy
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedInRaw = prefs.getBool(_keyIsLoggedIn);
    final isLoggedLegacy = prefs.getBool(_keyIsLogged);
    // Бэкап для старых сессий.
    final loginPresent = prefs.getString(_keyLogin) != null;
    return isLoggedInRaw ?? isLoggedLegacy ?? loginPresent;
  }

  // ЖАҢА: Сабақ біткенде прогресті жаңарту функциясы
  // Осы функция шақырылмаса, қайта кіргенде бәрі 1-сабақтан басталады
  Future<void> updateProgress(int newProgress, int addedXp) async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString(_keyLogin);

    // Обновляем Xp/Progress и в legacy ключах, и в ключах, привязанных к логину.
    int currentXpLegacy = prefs.getInt(_keyXp) ?? 0;
    await prefs.setInt(_keyProgress, newProgress);
    await prefs.setInt(_keyXp, currentXpLegacy + addedXp);

    if (login != null) {
      final currentXpPerUser = prefs.getInt(_xpKeyFor(login)) ?? currentXpLegacy;
      await prefs.setInt(_progressKeyFor(login), newProgress);
      await prefs.setInt(_xpKeyFor(login), currentXpPerUser + addedXp);
    }
  }

  // Сақталған пайдаланушыны жүктеу
  Future<UserAccount?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString(_keyLogin);
    final isLoggedInRaw = prefs.getBool(_keyIsLoggedIn);
    final isLoggedRaw = prefs.getBool(_keyIsLogged);
    // Бэкап для старых сессий: если флага нет, но login присутствует — считаем, что пользователь залогинен.
    final isLogged = isLoggedInRaw ?? isLoggedRaw ?? login != null;
    
    if (login != null && isLogged) {
      final progressFromUser = prefs.getInt(_progressKeyFor(login));
      final xpFromUser = prefs.getInt(_xpKeyFor(login));

      return UserAccount(
        login: login,
        password: "", // Парольді сақтамаймыз
        progress: progressFromUser ?? prefs.getInt(_keyProgress) ?? 1,
        xp: xpFromUser ?? prefs.getInt(_keyXp) ?? 0,
      );
    }
    return null;
  }

  // Деректерді өшіру (Шығу)
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Не удаляем chat history / saved codes (они привязаны к логину).
    // Удаляем только сессионные данные.
    await prefs.remove(_keyLogin);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyIsLogged);
    await prefs.remove(_keyProgress); // legacy
    await prefs.remove(_keyXp); // legacy
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

  // =========================
  // Compiler draft state (per user)
  // =========================

  Future<void> saveCompilerDraft({
    required String login,
    required String code,
    required String output,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'code': code,
      'output': output,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_compilerDraftKey(login), jsonEncode(payload));
  }

  Future<Map<String, String>> loadCompilerDraft(String login) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_compilerDraftKey(login));
    if (raw == null || raw.trim().isEmpty) {
      return const {'code': '', 'output': ''};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {'code': '', 'output': ''};
      final code = decoded['code'];
      final output = decoded['output'];
      return {
        'code': code is String ? code : '',
        'output': output is String ? output : '',
      };
    } catch (_) {
      return const {'code': '', 'output': ''};
    }
  }
}