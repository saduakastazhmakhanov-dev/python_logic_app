import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // Judge0 - тегін балама сервис
  final String _apiUrl = "https://judge0-ce.p.rapidapi.com/submissions?wait=true";
  final String _apiKey = "89625574cbmsh88f61c28c869917p1b0266jsn266159508e68"; // Тегін сынақ кілті

  Future<String> executePythonCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "x-rapidapi-key": _apiKey,
          "x-rapidapi-host": "judge0-ce.p.rapidapi.com",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "language_id": 71, // Python 3
          "source_code": code,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['stdout'] ?? data['stderr'] ?? data['compile_output'] ?? "Нәтиже жоқ";
      } else {
        return "Сервер жауап бермеді. Басқа сервис тексерілуде...";
      }
    } catch (e) {
      return "Қате: $e";
    }
  }
}