import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiTutorService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyD5GogFRtWtBF14GGZ2pHCmdqKSgS-L1K0',
  );
  static const String _modelName = 'gemini-2.0-flash';

  GenerativeModel get _model => GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
      );

  /// Жалпы чат сұрағы (AI экраны үшін)
  Future<String> sendChatMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) {
      return 'Сұрақ бос болмауы керек.';
    }

    final keyError = _validateApiKey();
    if (keyError != null) return keyError;

    const systemPrompt = '''
Сен мектептегі Python бағдарламалау тьюторысың.
Оқушыға қазақ тілінде қысқа, түсінікті жауап бер.
Дайын кодты толығымен берме — тек логикалық бағыт-бағдар бер.
''';

    try {
      final response = await _model.generateContent([
        Content.text('$systemPrompt\n\nОқушы сұрағы: $userMessage'),
      ]);
      return _extractText(response);
    } catch (e, st) {
      debugPrint('Gemini sendChatMessage error: $e');
      debugPrintStack(stackTrace: st);
      return _formatError(e);
    }
  }

  /// Компилятор қатесі бойынша кеңес
  Future<String> getAiHint(String studentCode, String compilerOutput) async {
    final keyError = _validateApiKey();
    if (keyError != null) return keyError;

    final prompt = '''
Сен мектептегі ағылшын тілі мен Python бағдарламалау логикасын біріктіріп үйрететін AI Тьюторсың.
Оқушы мына Python кодын жазды:
$studentCode

Компилятордың қайтарған нәтижесі немесе қатесі:
$compilerOutput

МАҢЫЗДЫ НҰСҚАУ:
1. Оқушыға ешқандай жағдайда ДАЙЫН ДҰРЫС КОДТЫ БЕРМЕ!
2. Қатенің неден шыққанын оқушыға қазақ тілінде өте қарапайым, қысқа әрі түсінікті тілмен түсіндір.
3. Оқушыға кодты өзі түзетуі үшін тек логикалық бағыт-бағдар (подсказка) бер.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _extractText(response);
    } catch (e, st) {
      debugPrint('Gemini getAiHint error: $e');
      debugPrintStack(stackTrace: st);
      return _formatError(e);
    }
  }

  String? _validateApiKey() {
    if (_apiKey.isEmpty) {
      return 'Gemini API кілті орнатылмаған. Қосымшаны '
          '--dart-define=GEMINI_API_KEY=ЖАҢА_GEMINI_KEY арқылы іске қосыңыз.';
    }

    if (_apiKey.startsWith('sk-')) {
      return 'Бұл OpenAI API кілті. Бұл қосымша google_generative_ai пакетін қолданады, '
          'сондықтан Google AI Studio-дан алынған Gemini API кілті керек.';
    }

    return null;
  }

  String _extractText(GenerateContentResponse response) {
    final text = response.text?.trim();
    if (text != null && text.isNotEmpty) return text;
    return 'Gemini бос жауап қайтарды.';
  }

  String _formatError(Object error) {
    final msg = error.toString();

    if (msg.contains('CONSUMER_SUSPENDED') ||
        msg.contains('has been suspended')) {
      return 'API кілті Google тарапынан тоқтатылған. '
          'Google AI Studio арқылы жаңа Gemini кілт жасап, қосымшаны сол кілтпен іске қосыңыз.';
    }
    if (msg.contains('API_KEY_INVALID') || msg.contains('API key not valid')) {
      return 'API кілті жарамсыз. Google AI Studio-дан жаңа Gemini кілт алыңыз.';
    }
    if (msg.contains('API_KEY_SERVICE_BLOCKED') || msg.contains('are blocked')) {
      return 'Бұл API кілтіне Generative Language API рұқсат берілмеген. '
          'AI Studio-да жасалған Gemini кілтін қолданыңыз.';
    }
    if (msg.contains('not found') || msg.contains('NOT_FOUND')) {
      return 'Модель табылмады ($_modelName). Модель атауын немесе API қолжетімділігін тексеріңіз.';
    }
    if (msg.contains('quota') || msg.contains('RESOURCE_EXHAUSTED')) {
      return 'API лимиті аяқталды. Біраз күтіп, қайта көріңіз.';
    }

    return 'Gemini-ге қосылу кезінде қате: $msg';
  }
}
