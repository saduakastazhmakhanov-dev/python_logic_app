// lib/services/ai_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // Сенің жаңа API кілтің қосылды
  static const String _apiKey = 'AIzaSyBkFb_2ZXvpEAPEfM2Y5YfrV3xBDyK41UU';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AIService() {
    _model = GenerativeModel(
      model: 'models/gemini-pro',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        "Сен мектеп оқушыларына Python үйрететін мейірімді мұғалімсің. Жауаптарды қарапайым мысалдармен, қазақ немесе орыс тілінде бер."
      ),
    );
    _chat = _model.startChat();
  }

  ChatSession get chatSession => _chat;

  Future<String?> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      print("AI Service Error: $e");
      return "Кешіріңіз, AI қазір жауап бере алмай тұр: $e";
    }
  }
}