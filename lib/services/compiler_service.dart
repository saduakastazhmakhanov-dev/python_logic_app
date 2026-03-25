import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  final String _url = "https://glot.io/api/run/python/latest";

  Future<String> executePythonCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "files": [{"name": "main.py", "content": code}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['stdout'] + data['stderr'];
      } else {
        return "Сервер қатесі: ${response.statusCode}";
      }
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}