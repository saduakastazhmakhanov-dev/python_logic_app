import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // Вебте CORS блогын айналып өтуге арналған прокси мен тұрақты Judge0 API
  final String _proxyUrl = "https://corsproxy.io/?";
  final String _apiUrl = "https://judge0-ce.p.sulu.sh/submissions?wait=true";

  Future<String> executePythonCode(String code) async {
    try {
      final apiUri = Uri.parse(_apiUrl);
      // Веб үшін екі сілтемені біріктіреміз
      final proxiedUri = Uri.parse('$_proxyUrl${apiUri.toString()}');

      final response = await http.post(
        proxiedUri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "source_code": code,
          "language_id": 71, // Python 3
          "stdin": ""
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String stdout = data['stdout'] ?? "";
        String stderr = data['stderr'] ?? "";
        String compileOutput = data['compile_output'] ?? "";

        if (stderr.isNotEmpty) {
          return stderr; // ИИ оқи алатын Python-ның ішкі қатесі
        }
        if (compileOutput.isNotEmpty) {
          return compileOutput;
        }
        if (stdout.isEmpty) {
          return "Код сәтті орындалды, бірақ экранға ештеңе шықпады (print() қолданыңыз).";
        }
        
        return stdout;
      } else {
        return "Сервер жауап бермеді. Статус: ${response.statusCode}";
      }
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}