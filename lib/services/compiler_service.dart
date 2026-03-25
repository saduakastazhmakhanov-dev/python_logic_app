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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "language": "python",
          "version": "3.10.0", // Нақты нұсқасы
          "files": [
            {
              "name": "main.py", // Файл аты міндетті
              "content": code
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final run = data['run'];
        final String output = run['output'] ?? "";
        final String stderr = run['stderr'] ?? "";
        
        if (stderr.isNotEmpty) {
          return "Python қатесі:\n$stderr";
        }
        
        return output.isEmpty ? "Бағдарлама орындалды (нәтиже жоқ)." : output;
      } else {
        // Басқа қателер келсе (мысалы, 400, 401)
        return "Сервер қатесі: ${response.statusCode}\nКомпилятор уақытша қолжетімсіз.";
      }
    } catch (e) {
      return "Интернет байланысын немесе браузер шектеуін тексеріңіз.\nҚате: $e";
    }
  }
}