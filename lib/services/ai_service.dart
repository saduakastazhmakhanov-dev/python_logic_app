import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
 
class AiTutorService {
  // Кілт кодта жазылмайды — build кезінде беріледі
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String _modelName = 'gemini-2.0-flash';
 
  Uri get _apiUrl => Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_apiKey');
 
  Future<String> sendChatMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) {
      return 'Сұрақ бос болмауы керек.';
    }
    if (_apiKey.isEmpty) {
      return 'Қате: GEMINI_API_KEY орнатылмаған.';
    }
 
    const systemPrompt =
        'Сен мектептегі Python бағдарламалау тьюторысың. '
        'Оқушыға қазақ тілінде қысқа, түсінікті жауап бер. '
        'Дайын кодты толығымен берме, тек логикалық бағыт-бағдар бер.';
 
    try {
      return await _sendRequest(
        systemPrompt: systemPrompt,
        userMessage: 'Оқушы сұрағы: $userMessage',
      );
    } catch (e, st) {
      debugPrint('Gemini sendChatMessage error: $e');
      debugPrintStack(stackTrace: st);
      return _formatError(e);
    }
  }
 
  Future<String> getAiHint(String studentCode, String compilerOutput) async {
    if (_apiKey.isEmpty) {
      return 'Қате: GEMINI_API_KEY орнатылмаған.';
    }
 
    const systemPrompt =
        'Сен мектептегі Python бағдарламалау логикасын үйрететін AI тьюторсың. '
        'Оқушыға қазақ тілінде өте қарапайым, қысқа және түсінікті жауап бер. '
        'Ешқашан дайын дұрыс кодты толық берме. '
        'Тек қатенің себебін түсіндіріп, оқушы өзі түзетуі үшін логикалық бағыт-бағдар бер.';
 
    final userMessage = '''
Оқушы мына Python кодын жазды:
$studentCode
 
Компилятордың қайтарған нәтижесі немесе қатесі:
$compilerOutput
''';
 
    try {
      return await _sendRequest(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
      );
    } catch (e, st) {
      debugPrint('Gemini getAiHint error: $e');
      debugPrintStack(stackTrace: st);
      return _formatError(e);
    }
  }
 
  Future<String> _sendRequest({
    required String systemPrompt,
    required String userMessage,
  }) async {
    final response = await http
        .post(
          _apiUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'system_instruction': {
              'parts': [
                {'text': systemPrompt}
              ]
            },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': userMessage}
                ]
              }
            ],
            'generationConfig': {
              'maxOutputTokens': 450,
              'temperature': 0.7,
            },
          }),
        )
        .timeout(const Duration(seconds: 30));
 
    final data = jsonDecode(response.body) as Map<String, dynamic>;
 
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        throw Exception(error['message']?.toString() ?? response.body);
      }
      throw Exception(response.body);
    }
 
    return _extractText(data);
  }
 
  String _extractText(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List?;
    if (candidates != null && candidates.isNotEmpty) {
      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts != null && parts.isNotEmpty) {
        final text = parts[0]['text']?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }
    }
    return 'Gemini бос жауап қайтарды.';
  }
 
  String _formatError(Object error) {
    return 'Gemini-ге қосылу кезінде қате: $error';
  }
}
 