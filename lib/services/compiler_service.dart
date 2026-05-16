import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // Тұрақты әрі тегін ашық Judge0 API сервері
  final String _apiUrl = "https://judge0-ce.p.sulu.sh/submissions?wait=true";

  Future<String> executePythonCode(String code) async {
    try {
      final uri = Uri.parse(_apiUrl);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "source_code": code,
          "language_id": 71, // 71 — Judge0 жүйесіндегі Python 3 нұсқасының ID-і
          "stdin": ""
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Код сәтті орындалғандағы нәтиже (stdout)
        String stdout = data['stdout'] ?? "";
        // Егер кодта синтаксистік немесе логикалық қате болса (stderr)
        String stderr = data['stderr'] ?? "";
        // Егер компиляция кезінде қате кетсе (compile_output)
        String compileOutput = data['compile_output'] ?? "";

        if (stderr.isNotEmpty) {
          return stderr; // Python қатесін қайтару
        }
        if (compileOutput.isNotEmpty) {
          return compileOutput;
        }
        if (stdout.isEmpty) {
          return "Код сәтті орындалды, бірақ экранға ештеңе шықпады (print() қолданыңыз).";
        }
        
        return stdout; // Дұрыс орындалған код нәтижесі
      } else {
        return "Сервер жауап бермеді: ${response.statusCode}";
      }
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}