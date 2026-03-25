import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  static const String _apiKey = 'AIzaSyBkFb_2ZXvpEAPEfM2Y5YfrV3xBDyK41UU';
  static const String _url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey";

  Future<String?> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": message}]}],
          "systemInstruction": {"parts": [{"text": "Сен Python мұғалімісің. Қазақша жауап бер."}]}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      return "AI уақытша қолжетімсіз.";
    } catch (e) {
      return "Байланыс қатесі: $e";
    }
  }
}