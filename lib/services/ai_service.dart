import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  // Ключ задаём безопасно через `flutter run ... --dart-define=GEMINI_API_KEY=...`
  // Не коммить ключ в репозиторий.
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  // Если вдруг конкретная модель даёт 404, попробуй другой вариант:
  // gemini-1.5-flash-latest (рекомендуется) или gemini-1.5-flash-002.
  static const String _model = 'gemini-1.5-flash-latest';

  final String _proxyUrl = "https://corsproxy.io/?";

  // Для Web обычно лучше использовать v1beta. Именно тут чаще всего причина 404.
  final String _apiUrlBase =
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent";

  Future<String?> sendMessage(String message) async {
    try {
      if (_apiKey.isEmpty) {
        return "AI ключ не задан. Передай GEMINI_API_KEY через --dart-define.";
      }

      final apiUri = Uri.parse(_apiUrlBase).replace(queryParameters: {
        'key': _apiKey,
      });

      // corsproxy.io принимает целевой URL в query-string после '?'
      final proxiedUri = Uri.parse('$_proxyUrl${apiUri.toString()}');

      final response = await http.post(
        proxiedUri,
        headers: const {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? text;
        try {
          final candidates = data['candidates'];
          if (candidates is List && candidates.isNotEmpty) {
            final firstCandidate = candidates.first;
            final content = firstCandidate['content'];
            final parts = content is Map ? content['parts'] : null;
            if (parts is List && parts.isNotEmpty) {
              final firstPart = parts.first;
              final t = firstPart['text'];
              if (t is String) text = t;
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