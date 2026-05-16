import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // Тікелей Piston API сервері (ешқандай прокси мен кілттің керегі жоқ)
  final String _apiUrl = "https://emkc.org/api/v2/piston/execute";

  Future<String> executePythonCode(String code) async {
    try {
      final uri = Uri.parse(_apiUrl);

      // Тек қана Content-Type қалдырамыз, ешқандай Authorization заголовогы керек емес
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          "language": "python",
          "version": "3.10.0", // Нақты нұсқасын жазамыз
          "files": [
            {
              "name": "main.py",
              "content": code
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['run'] != null) {
          String output = data['run']['output'] ?? "";
          if (output.isEmpty) {
            return "Код сәтті орындалды, бірақ экранға ештеңе шықпады (print() қолданыңыз).";
          }
          return output; // Кодтың нәтижесі немесе Python-ның ішкі қатесі
        }
        return "Нәтиже бос қайтты.";
      } else {
        // Егер сервер бәрібір қате берсе, оның ішкі хабарламасын көру үшін
        return "Сервер қатесі: ${response.statusCode}\nЖауап: ${response.body}";
      }
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}