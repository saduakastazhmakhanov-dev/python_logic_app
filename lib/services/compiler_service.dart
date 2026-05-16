import 'package:http/http.dart' as http;
import 'dart:convert';

class CompilerService {
  // Вебтегі CORS блоктарын айналып өту үшін Proxy қолданамыз
  final String _proxyUrl = "https://corsproxy.io/?";
  final String _apiUrl = "https://emkc.org/api/v2/piston/execute";

  Future<String> executePythonCode(String code) async {
    try {
      final apiUri = Uri.parse(_apiUrl);
      final proxiedUri = Uri.parse('$_proxyUrl${apiUri.toString()}');

      // Тегін Piston API үшін Authorization заголовогы керек емес, тек Content-Type жеткілікті
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        proxiedUri,
        headers: headers,
        body: jsonEncode({
          "language": "python",
          "version": "*", // "*" белгісі сервердегі бар ең соңғы тұрақты Python нұсқасын автоматты түрде таңдайды
          "files": [
            {
              "content": code // Файл атауынсыз тікелей кодты жібереміз
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Сауатты тексеріс: алдымен ішкі қателерді (compile немесе run) қарау
        if (data['run'] != null) {
          String output = data['run']['output'] ?? "";
          if (output.isEmpty) {
            return "Код сәтті орындалды, бірақ экранға ештеңе шықпады (print() қолданыңыз).";
          }
          return output; // Оқушының кодының нәтижесі немесе Python-ның қатесі (SyntaxError және т.б.)
        }
        return "Нәтиже жоқ";
      } else {
        return "Сервер қатесі: ${response.statusCode}.";
      }
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}
