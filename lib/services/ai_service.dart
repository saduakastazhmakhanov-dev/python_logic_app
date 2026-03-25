import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  static const String _apiKey = 'AIzaSyBkFb_2ZXvpEAPEfM2Y5YfrV3xBDyK41UU';
  final String _proxyUrl = "https://corsproxy.io/?";
  final String _apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey";

  Future<String?> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_proxyUrl + _apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": message}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      return "AI қатесі: ${response.statusCode}";
    } catch (e) {
      return "AI-ға қосылу мүмкін емес";
    }
  }
}