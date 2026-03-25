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
          // Веб нұсқада кейде қажет болуы мүмкін қосымша headers
        },
        body: jsonEncode({
          "language": "python",
          "version": "*", // "*" таңбасы ең соңғы қолжетімді нұсқаны автоматты түрде таңдайды
          "files": [
            {
              "content": code
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Piston API-ден келетін нәтижені немесе қатені (stderr) алу
        final String output = data['run']['output'] ?? "";
        final String stderr = data['run']['stderr'] ?? "";
        
        if (stderr.isNotEmpty) {
          return "Python қатесі:\n$stderr";
        }
        
        return output.isEmpty ? "Бағдарлама сәтті орындалды (нәтиже жоқ)." : output;
      } else if (response.statusCode == 401) {
        return "Серверге кіруге рұқсат жоқ (401). API шектеулерін тексеріңіз.";
      } else {
        return "Сервер қатесі: ${response.statusCode}\nЖауап: ${response.body}";
      }
    } catch (e) {
      return "Байланыс қатесі. Интернетті немесе API мекенжайын тексеріңіз.\nҚате: $e";
    }
  }
}