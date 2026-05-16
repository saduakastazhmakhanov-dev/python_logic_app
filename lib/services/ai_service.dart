import 'package:google_generative_ai/google_generative_ai.dart';

class AiTutorService {
  // Кілтті тікелей жазбаймыз, бірақ егер ортадан оқылмаса, бос қалмайтындай етеміз
  final String apiKey = const String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyD4JZeXFTobt5ZSe8Q3haQurc8OAwkPC-s'
  );

  Future<String> getAiHint(String studentCode, String compilerOutput) async {
    // Егер бәрібір бос болса немесе дефолт мән өзгермесе
    if (apiKey.isEmpty || apiKey == 'AIzaSyD4JZeXFTobt5ZSe8Q3haQurc8OAwkPC-s') {
      return "Қате: Gemini API кілті бапталмаған.";
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final prompt = '''
      Сен мектептегі ағылшын тілі мен Python бағдарламалау логикасын біріктіріп үйрететін AI Тьюторсың. 
      Оқушы мына Python кодын жазды: 
      $studentCode
      
      Компилятордың қайтарған нәтижесі немесе қатесі: 
      $compilerOutput
      
      МАҢЫЗДЫ НҰСҚАУ:
      1. Оқушыға ешқандай жағдайда ДАЙЫН ДҰРЫС КОДТЫ БЕРМЕ!
      2. Қатенің неден шыққанын оқушыға қазақ тілінде өте қарапайым, қысқа әрі түсінікті тілмен түсіндір.
      3. Оқушыға кодты өзі түзетуі үшін тек логикалық бағыт-бағдар бер.
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