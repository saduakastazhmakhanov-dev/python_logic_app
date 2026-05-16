import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // Өте тұрақты және CORS бұғаттауын толық айналып өтетін жаңа прокси
  final String _proxyUrl = "https://api.allorigins.win/raw?url=";
  final String _apiUrl = "https://judge0-ce.p.sulu.sh/submissions?wait=true";

  Future<String> executePythonCode(String code) async {
    try {
      final apiUri = Uri.parse(_apiUrl);
      // Сұраныс прокси арқылы дұрыс форматта жолданады
      final proxiedUri = Uri.parse('$_proxyUrl${Uri.encodeComponent(apiUri.toString())}');

      final response = await http.post(
        proxiedUri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "source_code": code,
          "language_id": 71, // Python 3 нұсқасының ID-і
          "stdin": ""
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String stdout = data['stdout'] ?? "";
        String stderr = data['stderr'] ?? "";
        String compileOutput = data['compile_output'] ?? "";

        if (stderr.isNotEmpty) {
          return stderr; // Python-ның ішкі қатесін ИИ Тьюторға жолдау
        }
        if (compileOutput.isNotEmpty) {
          return compileOutput;
        }
        if (stdout.isEmpty) {
          return "Код сәтті орындалды, бірақ экранға ештеңе шықпады (print() қолданыңыз).";
        }
        
        return stdout; // Сәтті орындалған код нәтижесі
      } else {
        return "Сервер жауап бермеді. Статус: ${response.statusCode}";
      }
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}