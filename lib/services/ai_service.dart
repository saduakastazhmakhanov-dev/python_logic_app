// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiTutorService {
  // Өзің жіберген OpenAI API кілті:
  final String apiKey = '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';

  Future<String> getAiHint(String studentCode, String compilerOutput) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final prompt = '''
      Сен информатика пәнінің мұғалімісің. 
      Оқушы мына Python кодын жазды: 
      $studentCode
      
      Компилятордың жауабы немесе қатесі: 
      $compilerOutput
      
      Маңызды нұсқау: Оқушыға дайын дұрыс кодты берме! Тек қатенің неден шыққанын түсіндіріп, оны қалай түзеу керектігіне қазақ тілінде қысқаша әрі түсінікті логикалық бағыт-бағдар бер.
    ''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey', // API кілтті жіберу
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo", // немесе "gpt-4" деп ауыстыруға болады
          "messages": [
            {
              "role": "system",
              "content": "Сен мектеп оқушыларына бағдарламалауды үйрететін көмекшісің."
            },
            {
              "role": "user",
              "content": prompt
            }
          ],
          "temperature": 0.7, // Жауаптың креативтілігі
        }),
      );

      if (response.statusCode == 200) {
        // Қазақ әріптері дұрыс шығуы үшін utf8.decode қолданамыз
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        // Егер API кілт қате болса немесе ақшасы бітсе, осыны көрсетеді
        final errorData = jsonDecode(response.body);
        return "OpenAI сервері қате қайтарды: ${errorData['error']['message']}";
      }
    } catch (e) {
      return "Интернетке қосылу мүмкін болмады: $e";
    }
  }
}