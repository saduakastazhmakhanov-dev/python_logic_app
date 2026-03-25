// lib/services/compiler_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // Piston API - тегін код орындау сервисі
  static const String _apiUrl = 'https://emkc.org/api/v2/piston/execute';

  Future<String> executePythonCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "language": "python",
          "version": "3.10.0",
          "files": [{"name": "main.py", "content": code}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['run']['output'] ?? "Нәтиже бос.";
      } else {
        return "Сервер қатесі: ${response.statusCode}";
      }
    } catch (e) {
      return "Интернет байланысын тексеріңіз.\nҚате: $e";
    }
  }
}