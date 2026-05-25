// lib/services/compiler_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompilerService {
  // Экрандағы атауға сәйкес болу үшін функция атын executePythonCode деп өзгерттік
  Future<String> executePythonCode(String code) async {
    final url = Uri.parse('https://emkc.org/api/v2/piston/execute');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "language": "python",
          "version": "3.10.0", 
          "files": [
            {"content": code}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['run']['output'] ?? "Нәтиже жоқ";
      } else {
        return "Сервер қатесі: ${response.statusCode}";
      }
    } catch (e) {
      return "Интернетке қосылу мүмкін болмады: $e";
    }
  }
}