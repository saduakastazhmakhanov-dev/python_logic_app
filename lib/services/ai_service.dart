// lib/services/ai_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // МАҢЫЗДЫ: Өз API кілтіңізді осында қойыңыз
  static const String _apiKey = 'AIzaSyDhrv3GZ4gRkRvKTANJ3ltUWfF6Sp8ElI0';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
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
      return null;
    }
  }
}