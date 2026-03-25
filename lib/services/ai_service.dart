import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'AIzaSyBkFb_2ZXvpEAPEfM2Y5YfrV3xBDyK41UU';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Пакетті жаңартқан соң осы нұсқа істейді
      apiKey: _apiKey,
    );
    _chat = _model.startChat();
  }

  Future<String?> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      return "Қате: $e";
    }
  }
}