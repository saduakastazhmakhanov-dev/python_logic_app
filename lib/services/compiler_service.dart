import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // CORS шектеуін айналып өту үшін proxy қосамыз
  final String _proxyUrl = "https://corsproxy.io/?";
  final String _apiUrl = "https://emkc.org/api/v2/piston/execute";

  Future<String> executePythonCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(_proxyUrl + _apiUrl), // Proxy-ді алдына тіркейміз
        body: jsonEncode({
          "language": "python",
          "version": "3.10.0",
          "files": [{"name": "main.py", "content": code}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['run']['output'] ?? "Нәтиже бос";
      } else {
        return "Сервер жауабы: ${response.statusCode}";
      }
    } catch (e) {
      return "Қате: $e";
    }
  }
}