import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  final String _apiUrl = 'https://emkc.org/api/v2/piston/execute';

  Future<String> executePythonCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
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
        return "Қате коды: ${response.statusCode}\nЖауап: ${response.body}";
      }
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}