import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  // OpenAI key задавай безопасно через `flutter run ... --dart-define=OPENAI_API_KEY=...`
  // Не коммить ключ в репозиторий.
  static const String _apiKeyFallback =
      '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';
  static const String _apiKeyFromEnv = String.fromEnvironment('OPENAI_API_KEY');

  // Можешь переключить модель через env, но по умолчанию берём gpt-4o.
  static const String _model =
      String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o');

  // Для Flutter Web это чаще всего нужно, чтобы обойти CORS.
  // В продакшене лучше делать запросы с сервера (не хранить ключ в фронтенде).
  final String _proxyUrl = "https://corsproxy.io/?";

  static const String _socraticSystemPrompt = '''
Sen "Python Logic App" ішіндегі Python тьюторысың. Негізгі мақсатың — оқушының алгоритмдік ойлауын дамыту.

Маңызды ереже (Сократтық әдіс):
- Оқушы қате жіберсе немесе "шешімін бер" десе де, бірден дайын жауапты/соңғы кодты берме.
- Оның орнына 1–3 қысқа жетелеуші сұрақ қой: айнымалы мәні қалай өзгерді, цикл неше рет жүреді, шарт қашан true болады, т.б.
- Қажет болса, тек бір шағын hint бер (формула, аралық қадам), бірақ финал нәтижені толық ашып тастама.
- Оқушы дұрыс бағытқа келсе, жауапты өзі айтуына мүмкіндік бер: "Ендеше сенің ойыңша нәтиже қанша болады?"

Стиль:
- Түсінікті, жылы, қысқа Kazakh тілінде жаз.
- Код мысалдары қысқа болсын (3–8 жол), қажет болса моноқаріппен бер.
''';

  String get _apiKey => _apiKeyFromEnv.isNotEmpty ? _apiKeyFromEnv : _apiKeyFallback;

  Future<String?> sendMessage(String message) async {
    try {
      if (_apiKey.isEmpty) {
        return "AI ключ не задан. Передай OPENAI_API_KEY через --dart-define.";
      }

      final apiUri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final proxiedUri = Uri.parse('$_proxyUrl${apiUri.toString()}');

      final response = await http.post(
        proxiedUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': _socraticSystemPrompt},
            {'role': 'user', 'content': message}
          ],
          // На случай, если провайдер ограничивает max tokens.
          'max_tokens': 512,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? text;
        try {
          final choices = data['choices'];
          if (choices is List && choices.isNotEmpty) {
            final firstChoice = choices.first;
            if (firstChoice is Map) {
              final message = firstChoice['message'];
              if (message is Map) {
                final content = message['content'];
                if (content is String) text = content;
              }
            }
          }
        } catch (_) {
          // ignore parse errors
        }

        if (text != null) return text;
        return "AI: неверный формат ответа";
      }

      // Для дебага полезно увидеть код и небольшую часть тела ответа.
      final bodyPreview = response.body.isNotEmpty
          ? response.body.substring(0, response.body.length.clamp(0, 300))
          : '';
      return "AI қатесі: ${response.statusCode}. $bodyPreview";
    } catch (e) {
      return "AI-ға қосылу мүмкін емес";
    }
  }
}