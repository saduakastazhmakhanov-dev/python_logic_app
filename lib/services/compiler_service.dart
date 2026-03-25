import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // CORS блоктарын айналып өту үшін Proxy
  final String _proxyUrl = "https://corsproxy.io/?";
  final String _apiUrl = "https://emkc.org/api/v2/piston/execute";

  // Если ты оставляешь этот сервис для Piston/JDoodle:
  // Ключ задаём безопасно через `flutter run ... --dart-define=PISTON_API_KEY=...`
  // Не коммить ключ в репозиторий.
  //
  // ВАЖНО: у разных Piston-провайдеров может отличаться имя/формат заголовка.
  // Я поставил самый частый вариант: Authorization: Bearer <key>.
  // Если после вставки ключа всё равно 401 — скажи, и я подгоню под точный формат,
  // сверившись с твоими логами ответа.
  static const String _pistonApiKey =
      String.fromEnvironment('PISTON_API_KEY', defaultValue: '');

  Future<String> executePythonCode(String code) async {
    try {
      final apiUri = Uri.parse(_apiUrl);
      final proxiedUri = Uri.parse('$_proxyUrl${apiUri.toString()}');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (_pistonApiKey.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer $_pistonApiKey';
      }

      final response = await http.post(
        proxiedUri,
        headers: headers,
        body: jsonEncode({
          "language": "python",
          "version": "3.10.0",
          "files": [
            {"name": "main.py", "content": code}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['run']['output'] ?? "Нәтиже жоқ";
      } else {
        final bodyPreview = response.body.isNotEmpty
            ? response.body.substring(0, response.body.length.clamp(0, 300))
            : '';
        return "Сервер қатесі: ${response.statusCode}. $bodyPreview";
      }
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}