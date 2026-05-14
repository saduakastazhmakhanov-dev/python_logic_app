import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:html' as html; // GitHub Secrets-тен кілтті алу үшін керек

class AiTutorService {
  // GitHub Secrets-ке сақтаған GEMINI_API_KEY мәнін алу
  // Егер жергілікті компьютерде (local) іске қоссаң, 'КІЛТТІ_ОСЫНДА_УАҚЫТША_ҚОЙ'
  final String apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  Future<String> getAiHint(String studentCode, String compilerOutput) async {
    if (apiKey.isEmpty) {
      return "Қате: Gemini API кілті табылмады. GitHub Secrets бөлімін тексеріңіз.";
    }

    // Gemini 1.5 Flash моделін қолданамыз (жылдам әрі тегін нұсқасы бар)
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final prompt = '''
      Сен информатика пәнінің мұғалімісің. 
      Оқушы мына Python кодын жазды: 
      $studentCode
      
      Компилятордың жауабы немесе қатесі: 
      $compilerOutput
      
      Маңызды нұсқау: Оқушыға дайын дұрыс кодты берме! 
      Тек қатенің неден шыққанын түсіндіріп, оны қалай түзеу керектігіне қазақ тілінде қысқаша әрі түсінікті логикалық бағыт-бағдар бер.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        return response.text!;
      } else {
        return "Gemini бос жауап қайтарды.";
      }
    } catch (e) {
      return "Gemini-ге қосылу кезінде қате шықты: $e";
    }
  }
}